module Validations
  class Person
    include ActiveLayer::Validations

    validates :first_name, :last_name, :presence => true

  end
end
