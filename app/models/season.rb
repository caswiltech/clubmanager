class Season < ActiveRecord::Base
  belongs_to :club
  has_many :season_divisions
  has_many :teams, :through => :season_divisions
  has_many :user_roles, :as => :assignee, :dependent => :destroy
  has_many :payment_packages, :through => :season_divisions
  has_many :registrations, :through => :season_divisions
  has_many :registration_questions
  
  scope :accepting_registrations_now,
    where("seasons.start_reg_on <= current_date AND seasons.end_reg_on > current_date").
    order("seasons.end_reg_on, seasons.id").
    readonly(false)
  
end
