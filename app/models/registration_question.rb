class RegistrationQuestion < ActiveRecord::Base
  belongs_to :club
  belongs_to :season
  belongs_to :division
  has_many :registration_question_response_options, :dependent => :destroy
  has_many :registration_question_responses, :dependent => :destroy
    
end