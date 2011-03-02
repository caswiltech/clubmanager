class Registration < ActiveRecord::Base
  belongs_to :club
  belongs_to :player
  belongs_to :season
  belongs_to :division
  belongs_to :team
  # has_many :people, :through => :registrations_people
  belongs_to :parent_guardian1, :class_name => "Person"
  belongs_to :parent_guardian2, :class_name => "Person"

  accepts_nested_attributes_for :player
  accepts_nested_attributes_for :parent_guardian1
  accepts_nested_attributes_for :parent_guardian2
  
  attr_accessor :waiver
  
  validate :waiver, :acceptance => true, :on => :create
end