class RegistrationQuestion < ActiveRecord::Base
  belongs_to :club
  belongs_to :season
  belongs_to :division
  has_many :registration_question_response_options
  
  def self.questions_for_registration(registration)
    questions = registration.club.registration_questions.where("(season_id IS NULL AND division_id IS NULL) OR (season_id IS NULL and division_id = ?) OR (season_id = ? AND division_id IS NULL) OR (season_id = ? AND division_id = ?)", registration.season.id, registration.division.id, registration.season.id, registration.division.id)
  end
end