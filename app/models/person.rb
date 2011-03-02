class Person < ActiveRecord::Base
  has_one :player
  belongs_to :club
  has_many :registrations, :class_name => 'Registration', :foreign_key => 'parent_guardian1_id'
  has_many :registrations, :class_name => 'Registration', :foreign_key => 'parent_guardian2_id'
end
