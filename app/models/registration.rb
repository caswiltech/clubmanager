class Registration < ActiveRecord::Base
  belongs_to :club
  belongs_to :player
  belongs_to :season
  belongs_to :division
  belongs_to :team
  has_many :registrations_people
  has_many :registration_question_responses
  belongs_to :parent_guardian1, :class_name => "Person"
  belongs_to :parent_guardian2, :class_name => "Person"
  accepts_nested_attributes_for :parent_guardian1
  accepts_nested_attributes_for :parent_guardian2

  accepts_nested_attributes_for :registrations_people
  accepts_nested_attributes_for :player
  # accepts_nested_attributes_for :parent_guardian2, :reject_if => proc { |attrs| attrs['first_name'].blank? && attrs['last_name'].blank? }
  
  attr_accessor :waiver
  
  validates :waiver, :acceptance => {:message => "This waiver must be accepted in order to finalize the registration"}, :on => :update
  validates :promotion_source, :presence => {:message => "Please select an option as your input on how you came to know about our program is vital to our future promotional efforts"}, :on => :update
  
  def registration_questions=
    RegistrationQuestion.questions_for_registration(self)
  end
  
end