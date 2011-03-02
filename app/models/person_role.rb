class PersonRole < ActiveRecord::Base
  belongs_to :club
  has_many :registration_peoples
end