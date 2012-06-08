class Season < ActiveRecord::Base
  belongs_to :club
  has_many :season_divisions
  has_many :teams, :through => :season_divisions
  has_many :user_roles, :as => :assignee, :dependent => :destroy
  has_many :payment_packages, :through => :season_divisions
  has_many :registrations
  has_many :registration_questions
  
  scope :accepting_registrations_now,
    where("seasons.start_reg_on <= current_date AND seasons.end_reg_on > current_date").
    order("seasons.end_reg_on, seasons.id").
    readonly(false)
    
  scope :current,
    where("seasons.end_reg_on >= current_date").
    order("seasons.end_season_on DESC, seasons.end_reg_on DESC, seasons.name")
      
  scope :past,
    where("seasons.end_reg_on < current_date").
    order("seasons.end_reg_on, seasons.name")
    
  def self.season_accepting_registrations(club, season_id)
    season = nil
    if season_id.to_i.is_a?(Numeric)
      unless club.seasons.accepting_registrations_now.where(:id => season_id.to_i).first.nil?
        season = Season.find_by_id(club.seasons.accepting_registrations_now.where(:id => season_id.to_i).first.id)
      end
    end
    season
  end
  
  def taxreceipt_spantext
    if self.end_season_on.year == self.start_season_on.year
      "#{Date::MONTHNAMES[self.start_season_on.month]} to #{Date::MONTHNAMES[self.end_season_on.month]} #{self.start_season_on.year}"
    else
      "#{Date::MONTHNAMES[self.start_season_on.month]}  #{self.start_season_on.year} to #{Date::MONTHNAMES[self.end_season_on.month]} #{self.end_season_on.year}"
    end
  end
end
