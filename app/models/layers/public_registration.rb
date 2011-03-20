module Layers
  class PublicRegistration
    include ActiveLayer::ActiveRecord

    all_attributes_accessible!

    validates :waiver, :acceptance => true, :on => :finalize

    validates_with Validations::Player, :attributes => :player
    validates_with Validations::Person, :attributes => :parent_guardian1
    validates_with Validations::Person, :attributes => :parent_guardian2
    
  end
end