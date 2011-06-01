class RegistrationQuestionResponse < ActiveRecord::Base
  belongs_to :registration
  belongs_to :registration_question
  belongs_to :registration_question_response_option
end