module Validations
  class RegistrationPerson
    include ActiveLayer::Validations

    validates_with Validations::Person, :attributes => :person

  end
end
