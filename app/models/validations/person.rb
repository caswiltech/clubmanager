module Validations
  class Person
    include ActiveLayer::Validations

    validates :first_name, :last_name, :presence => true
    validates_length_of :first_name, :maximum => 100
    validates_length_of :last_name, :maximum => 100
    
    validates :email, :email => true
    validates :alt_email, :email => true

  end
end
