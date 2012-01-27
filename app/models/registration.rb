class Registration < ActiveRecord::Base
  belongs_to :club
  belongs_to :player
  belongs_to :season
  belongs_to :division
  belongs_to :team
  has_many :registrations_people
  has_many :registration_question_responses, :dependent => :destroy
  belongs_to :parent_guardian1, :class_name => "Person"
  belongs_to :parent_guardian2, :class_name => "Person"

  accepts_nested_attributes_for :registrations_people, :allow_destroy => true
  accepts_nested_attributes_for :player
  accepts_nested_attributes_for :registration_question_responses, :reject_if => proc { |attrs| attrs['registration_question_response_option_id'].blank? && attrs['textresponse'].blank? }
  
  attr_accessor :waiver
  validates :waiver, :acceptance => {:message => "This waiver must be accepted in order to finalize the registration"}, :on => :update
  
  scope :by_player_name,
    select("registrations.*, people.first_name, people.last_name, players.birthdate").
    joins("inner join players on registrations.player_id = players.id").
    joins("inner join people on players.person_id = people.id").
    order("people.last_name, people.first_name")
  
  scope :by_reg_date,
    select("registrations.*, people.first_name, people.last_name, players.birthdate").
    joins("inner join players on registrations.player_id = players.id").
    joins("inner join people on players.person_id = people.id").
    order("registrations.created_at")
    
  scope :thisyear,
    joins("inner join seasons on registrations.season_id = seasons.id").
    where("seasons.end_season_on >= current_date")
  
  def registration_questions#=
    RegistrationQuestionResponse.questions_for_registration(self)
  end
  
  def player_name
    "#{self.player.person.first_name} #{self.player.person.last_name}"
  end
  
  def payment_total
    season_division = SeasonDivision.where(:season_id => self.season.id, :division_id => self.division.id).first
    # are there multiple payment packages for this SD?
    pp = nil
    if season_division.payment_packages.count > 1
      pp = season_division.payment_packages.where(:default => false).first
    else
      pp = season_division.payment_packages.first
    end
    "#{sprintf('%01.2f', pp.amount)}"
  end
  
  def payment_date
    "#{self.created_at.strftime('%B %d, %Y')}"
  end
    
end