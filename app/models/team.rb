class Team < ActiveRecord::Base
  belongs_to :season_division
  has_many :user_roles, :as => :assignee#, :dependent => :destroy
  has_many :registrations
  
  def season
    self.season_division.season
  end
  
  def division
    self.season_division.division
  end
  
  def club
    self.season_division.season.club
  end
end