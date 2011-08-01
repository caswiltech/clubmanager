class PersonRole < ActiveRecord::Base
  belongs_to :club
  has_many :registrations_people
end