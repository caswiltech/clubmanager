class RegistrationQuestionResponseOption < ActiveRecord::Base
  belongs_to :registration_question
  has_many :registration_question_responses
  
  scope :public_visible, where("(adminonly IS NULL) OR (adminonly = 'f')")
end