class RegistrationQuestionResponse < ActiveRecord::Base
  belongs_to :registration
  belongs_to :registration_question
  belongs_to :registration_question_response_option
    
  def self.questions_for_registration(registration, admin_mode = false)
    questions = registration.club.registration_questions
    if admin_mode
      questions = questions.where('editable_by > 0')
    else
      questions = questions.where('editable_by = 0')
    end
    if registration.division.present?
      questions.where("(season_id IS NULL AND division_id IS NULL) OR (season_id IS NULL and division_id = ?) OR (season_id = ? AND division_id IS NULL) OR (season_id = ? AND division_id = ?)", registration.season.id, registration.division.id, registration.season.id, registration.division.id)
    else
      questions.where("(season_id IS NULL AND division_id IS NULL) OR (season_id = ? AND division_id IS NULL)", registration.season.id)
    end
  end
  
  def self.populate_responses_for_registration(registration, options = {})
    player_fields = options[:player_fields].present? ? options[:player_fields] : nil
    questions = nil
    if player_fields.nil?
      Rails::logger.info "\n\n#{'x'*50}\n\n"
      Rails::logger.info "\n\nplayer_fields is nil #{options.inspect}\n\n"
      
      questions = questions_for_registration(registration).order("player_field DESC")
    else
      Rails::logger.info "\n\n#{'x'*50}\n\n"
      Rails::logger.info "\n\nplayer_fields is present #{options.inspect}\n\n"
      questions = questions_for_registration(registration).where(:player_field => player_fields)
    end
    responses = []
    questions.each do |q|
      # get those response options that are not admin-only, and that are default (or first in the list of non-defaults)
      if q.response_optional
        responses << registration.registration_question_responses.build(:registration_question => q)
      else
        options = q.registration_question_response_options.publicly_visible
        responses << registration.registration_question_responses.build(:registration_question => q, :registration_question_response_option_id => (options.empty? ? nil : options.first.id))
      end
    end
    responses
  end
  
  def self.create_default_responses_for_protected_questions(registration)
    questions = questions_for_registration(registration, true)
    responses = []
    questions.each do |q|
      # get those response options that are not admin-only, and that are default (or first in the list of non-defaults)
      options = q.registration_question_response_options
      responses << registration.registration_question_responses.create(:registration_question => q, :registration_question_response_option_id => (options.empty? ? nil : options.first.id))
    end
    responses    
  end
end