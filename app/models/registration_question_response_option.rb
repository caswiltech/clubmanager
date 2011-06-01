class RegistrationQuestionResponseOption < ActiveRecord::Base
  belongs_to :registration_question
  has_many :registration_question_responses
end