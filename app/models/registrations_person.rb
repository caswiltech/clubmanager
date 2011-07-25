class RegistrationsPerson < ActiveRecord::Base
  belongs_to :person_role
  belongs_to :registration
  belongs_to :person
  
  accepts_nested_attributes_for :person, :allow_destroy => true, :reject_if => proc { |attrs| attrs['first_name'].blank? && attrs['last_name'].blank? }
  
  scope :parent_guardians, joins('INNER JOIN person_roles ON registrations_people.person_role_id = person_roles.id').where("person_roles.role_abbreviation = 'PG'")
end