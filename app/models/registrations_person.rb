class RegistrationsPerson < ActiveRecord::Base
  belongs_to :person_role
  belongs_to :registration
  belongs_to :person
  
  accepts_nested_attributes_for :person
end