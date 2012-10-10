class Payment < ActiveRecord::Base
  belongs_to :club
  belongs_to :registration
  belongs_to :payment_option
  belongs_to :user

  def amount=(amount)
    write_attribute(:amount, amount * 100)
  end

  def amount
    read_attribute(:amount) / 100.0
  end
end