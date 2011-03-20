module Validations
  class PlayerPerson
    include ActiveLayer::Validations

    validates :first_name, :last_name, :street1, :city, :province, :country, :postal_code, :presence => true

  end
end
