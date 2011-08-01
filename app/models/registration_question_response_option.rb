class RegistrationQuestionResponseOption < ActiveRecord::Base
  belongs_to :registration_question
  has_many :registration_question_responses
  
  scope :publicly_visible, order("defaultresponse DESC").where(:adminonly => false) 
end