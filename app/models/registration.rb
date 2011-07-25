class Registration < ActiveRecord::Base
  belongs_to :club
  belongs_to :player
  belongs_to :season
  belongs_to :division
  belongs_to :team
  has_many :registrations_people
  has_many :registration_question_responses, :dependent => :destroy

  accepts_nested_attributes_for :registrations_people, :allow_destroy => true
  accepts_nested_attributes_for :player
  accepts_nested_attributes_for :registration_question_responses, :reject_if => proc { |attrs| attrs['registration_question_response_option_id'].blank? && attrs['textresponse'].blank? }
  
  attr_accessor :waiver
  validates :waiver, :acceptance => {:message => "This waiver must be accepted in order to finalize the registration"}, :on => :update
  
  def registration_questions#=
    RegistrationQuestionResponse.questions_for_registration(self)
  end
    
end