class RegistrationPerson < ActiveRecord::Base
  belongs_to :club
  belongs_to :person_role
  belongs_to :registration
  belongs_to :person
end