module Validations
  class Player
    include ActiveLayer::Validations

    validates :carecard, :birthdate, :gender, :presence => true
    validates_with Validations::PlayerPerson, :attributes => :person

  end
end
