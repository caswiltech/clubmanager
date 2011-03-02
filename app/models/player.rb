class Player < ActiveRecord::Base
  belongs_to :person
  has_many :registrations
  accepts_nested_attributes_for :person
  
end