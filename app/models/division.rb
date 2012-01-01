class Division < ActiveRecord::Base
  belongs_to :club
  has_many :season_divisions
  has_many :teams, :through => :season_divisions
  has_many :user_roles, :as => :assignee, :dependent => :destroy
  has_many :payment_packages, :through => :season_divisions
  has_many :registrations
  has_many :registration_questions

  def self.for_season_and_birthdate(season, birthdate, publicly_visible = false)
    season_divisions = SeasonDivision.for_season_and_birthdate(season,birthdate)
    season_divisions = season_divisions.publicly_visible if publicly_visible
    unless season_divisions.empty?
      season_divisions.first.division
    else
      nil
    end
  end
end