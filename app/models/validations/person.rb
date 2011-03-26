module Validations
  class Person
    include ActiveLayer::Validations

    validates :first_name, :last_name, :presence => true
    
    validates :email, :email => true
    validates :alt_email, :email => true

  end
end
