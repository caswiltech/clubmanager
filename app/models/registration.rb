class Registration < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :club
  belongs_to :player
  belongs_to :season
  belongs_to :division
  belongs_to :team
  has_many :registrations_people
  has_many :registration_question_responses, :dependent => :destroy
  belongs_to :registration_token
  belongs_to :payment_option
  belongs_to :quit
  has_many :payments
  
  # legacu and should be refactored out in the future
  belongs_to :parent_guardian1, :class_name => "Person"
  belongs_to :parent_guardian2, :class_name => "Person"

  accepts_nested_attributes_for :registrations_people, :allow_destroy => true
  accepts_nested_attributes_for :player
  accepts_nested_attributes_for :registration_question_responses, :reject_if => proc { |attrs| attrs['registration_question_response_option_id'].blank? && attrs['textresponse'].blank? }
  
  attr_accessor :waiver
  validates :waiver, :acceptance => {:message => "This waiver must be accepted in order to finalize the registration"}, :on => :update

  scope :unquit, where("quit_id IS NULL")
  
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
    
  scope :receipt_eligible,
    joins("inner join registration_question_responses on registrations.id = registration_question_responses.registration_id").
    joins("inner join registration_question_response_options on registration_question_responses.registration_question_response_option_id = registration_question_response_options.id").
    where("registration_question_response_options.response_value = 'Cheque' or registration_question_response_options.response_value = 'Credit Card'")
  
  def registration_questions#=
    RegistrationQuestionResponse.questions_for_registration(self)
  end
  
  def player_name
    "#{self.player.person.first_name} #{self.player.person.last_name}"
  end
  
  def payment_total
    "#{sprintf('%01.2f', self.reg_fee)}"
  end
  
  def payment_date
    "#{self.created_at.strftime('%B %d, %Y')}"
  end

  def reg_fee
    season_division = SeasonDivision.where(:season_id => self.season.id, :division_id => self.division.id).first
    # are there multiple payment packages for this SD?
    pp = nil
    if season_division.payment_packages.count > 1
      if self.created_at > Date.new(2011,7,13)
        pp = season_division.payment_packages.where(:default => true).first
      else
        pp = season_division.payment_packages.where(:default => false).first
      end
    else
      pp = season_division.payment_packages.first
    end
    pp.amount
  end

  def amount_paid
    amount = 0.0
    self.payments.each do |p|
      amount += p.amount
    end
    amount
  end

  def amount_owing
    reg_fee - amount_paid
  end
    
end