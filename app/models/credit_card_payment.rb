class CreditCardPayment < ActiveRecord::Base
  belongs_to :registration
  
  attr_accessor :billing_name , :billing_street1, :billing_street2, :billing_city, :billing_province, :billing_country, :billing_postalcode

  def response=(response)
    parameters = {}
    parameters = response.params if response.respond_to? :params
    begin
      self.success = response.success?
      self.auth_code = response.authorization if response.respond_to? :authorization
      self.message = response.message if response.respond_to? :message
      self.params = parameters
    rescue ActiveMerchant::ActiveMerchantError => e
      self.success = false
      self.auth_code = nil
      self.message = e.message
      self.params = parameters
    end
  end


  def purchase
    response = process_purchase
    trans = transactions.create!(:action => 'purchase', :amount => total, :response => response)
    if response.success?
      #NOTE: setting complete=true triggers the observer model to send notifications and fulfillment
      rightnow = Time.now.utc
      self.update_attributes(:purchased_at => rightnow, :paid => true)

      updated_product_signing_status if self.is_code_signing_order?

      self.send_later(:background_fulfillment)
      ContactMailer.send_later(:deliver_order_receipt_email, self, "#{sprintf('%02d', self.cc_exp_month)} / #{self.cc_exp_year}")
    end

    response
  end

  def background_fulfillment
    self.order_items.each do |item|
      item.fulfill
    end

    #shipwire fulfillment
    if self.items_to_ship.blank?
      self.complete = true
    else
      self.complete = true if submit_shipping
    end

  end

  def has_training_items?
    self.order_items.each do |item|
      return true if item.is_training?
    end

    false
  end

  def is_code_signing_order?
    return false if order_items.size != 1
    self.order_items.first.catalogs_product.product.is_code_signing?
  end

  def shippable_items
    self.order_items.collect { |item| item if item.is_shippable? }
  end

  def training_items
    self.order_items.collect { |item| item if item.is_training? }
  end

  def submit_shipping
    #if shipping fulfillment is successful, then
    return true unless self.has_shippable_items? && self.tracking_number.nil?

    options = {
      :shipping_method => self.shipping_method,
      :email => Order.fulfillment_notify_email
    }

    address = self.address_hash(self.ship_to, self.shipping_address)
    response = Order.fulfillment_gateway.fulfill(self.id, address, self.items_to_ship, options)
    #TODO: check to see if we can extract and set :amount => xxx from the response - :test gateway doesn't return any amount
    trans = transactions.create!(:action => 'shipping_fulfillment', :response => response, :auth_code => response.params['transaction_id'])

    if response.success?
      response2 = Order.fulfillment_gateway.fetch_tracking_numbers({ 'ShipwireId' => trans.auth_code })
      #Rails::logger.info "\n\n#{'x'*50}\n\nresponse2\n#{response2.inspect}\n\n"

      transactions.create!(:action => 'tracking_number', :response => response)
      # if this fails, we should still report success; tracking # will be emailed by shipwire
      tr_nums = response2.tracking_numbers
      if response2.success? && tr_nums && !tr_nums.empty? && tr_nums.respond_to?(:to_s)
        self.tracking_number = tr_nums.to_s #todo: see how to represent these #'s
      else
        self.tracking_number = 'N/A'
      end

      #update the fulfilled status of shippable order items
      self.shippable_items.each do |item|
        item.update_attributes(:fulfilled => true)
      end

      self.save

    else
      Rails::logger.info "\n\n#{'x'*50}\n\nUnsuccessful response to initial order fulfillment\n#{response.inspect}\n\n"
    end

    response.success?
  end

  class << self
    #THREADSAFETY - this looks dodgy
    @@payflow_gateway = nil
    @@fulfillment_gateway = nil
    @@shipping_gateway = nil

    def standard_gateway
      create_gateways unless @@payflow_gateway
      @@payflow_gateway
    end

    def fulfillment_gateway
      create_gateways unless @@fulfillment_gateway
      @@fulfillment_gateway
    end

    def shipping_gateway
      create_gateways unless @@shipping_gateway
      @@shipping_gateway
    end

    def fulfillment_notify_email
      @@shipwire_email ||= 'admin@partnerpedia.com'
    end

    def fulfillment_currency
      @@shipping_currency ||= Currency.find_by_code('USD')
    end

    private

    def create_gateways
      config = YAML.load_file(RAILS_ROOT + "/config/active_merchant.yml")[RAILS_ENV].symbolize_keys
      @@shipwire_email = config[:shipwire_email]
      @@shipping_currency = Currency.find_by_code(config[:shipwire_currency])

      if RAILS_ENV == 'test'
        @@payflow_gateway = ActiveMerchant::Billing::BogusGateway.new
      else
        @@payflow_gateway = ActiveMerchant::Billing::PayflowGateway.new(payflow_options(config))
      end

      @@fulfillment_gateway = ActiveMerchant::Fulfillment::ShipwireService.new(shipwire_options(config))

      @@shipping_gateway = ActiveMerchant::Shipping::Shipwire.new(shipwire_options(config))
    end


    def payflow_options(config)
      {
        :login    => config[:login],
        :user     => config[:user],
        :password => config[:password]
      }
    end



    def shipwire_options(config)
      {
        :login    => config[:shipwire_email],
        :password => config[:shipwire_pass],
      }
    end

  end

  def items_for_fulfillment
    items = self.order_items.collect do |item|
      { :sku => item.product.sku, :quantity => item.quantity } if item.is_shippable? && item.product.sku
    end
    items.compact
  end

  def shipping_location
    address = self.shipping_address
    raise "Must set a shipping address" if address.blank?
    ActiveMerchant::Shipping::Location.new(address_hash(self.ship_to, address))
  end

  def total_in_cents
    (total*100).round
  end

  def process_purchase
    self.total = total_price
    Order.standard_gateway.purchase(total_in_cents, credit_card, standard_purchase_options)
  end

  def credit_card
    split_name = self.cc_name.split(' ')
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => self.card_type,
      :number             => self.cc_number,
      :verification_value => self.cc_cvv,
      :month              => self.cc_exp_month,
      :year               => self.cc_exp_year,
      :first_name         => split_name[0] || '',
      :last_name          => split_name[1] || '')
  end

  def standard_purchase_options
    {
      :currency         => self.currency.code,
      :ip               => ip_address,
      :billing_address  => address_hash(self.bill_to, billing_address)
    }
  end

  def address_hash(name, address)
    {
      :name       => name || self.user.name,
      :address1   => address.street1,
      :address2   => address.street2,
      :city       => address.city,
      :state      => address.state_code,
      :country    => address.country_code,
      :zip        => address.postal_code
    }
  end
end