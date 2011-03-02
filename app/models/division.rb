class Division < ActiveRecord::Base
  belongs_to :club
  has_many :season_divisions
  has_many :teams, :through => :season_divisions
  has_many :user_roles, :as => :assignee, :dependent => :destroy
  has_many :payment_packages, :through => :season_divisions
  has_many :registrations, :through => :season_divisions
  has_many :registration_questions
end