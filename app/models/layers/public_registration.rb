module Layers
  class PublicRegistration
    include ActiveLayer::ActiveRecord

    all_attributes_accessible!

    validates :waiver, :acceptance => true, :on => :update

    validates_with Validations::Player, :attributes => :player
    validates_with Validations::RegistrationPerson, :attributes => :registrations_people
    
  end
end