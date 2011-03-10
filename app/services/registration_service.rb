class RegistrationService < Service::Base
  def create_registration(params)
    status = client_details.is_store_admin? ? 'approved' : "pending"

    params.merge!(:creator_id => client_details.user.id)
    product_type_id = params.delete(:product_type_id)

    if product_type_id.present?
      product_type = ProductType.find(product_type_id.to_i)
    end
    if product_type.blank?
      product_type = ProductType.where(:name => ProductType::TYPES[:software]).first
      if product_type.blank?
        product_type = ProductType.first
      end
    end

    product = Product.new(:product_type => product_type)
    product_version = ProductVersion.new(:product => product)
    layer = Layers::ProductVersion.new(product_version)
    layer.attributes = params

    if layer.valid?
      # set up product_version_list

      if product_version.linked_product_id.blank?
        owner_type = 'Company'
        owner_id = client_details.company.id
        product = Product.create!(:product_type_id => product_type_id, :owner_type => owner_type, :owner_id => owner_id)
      else
        product = ProductVersion.find(layer.linked_product_id).product
      end

      layer.product = product
      layer.save
    else
      result(:failure)
    end

    product_version
  end


  def update_product(product_version, params)
    layer = Layers::ProductVersion.new(product_version)

    unless layer.update_attributes(params)
      result(:failure)
    end

    product_version
  end

  def destroy_product(product_version)
    product = product_version.product
    publications = product_version.publications
    if product_version.destroy
      publications.each do |publication|
        update_request(publication, "deleted", client_details)
      end
      product.destroy if product.product_versions.count == 0
    else
      result(:failure)
    end
  end

end

