class SeasonDivision < ActiveRecord::Base
  belongs_to :season
  belongs_to :division
  has_many :payment_packages, :dependent => :destroy

  scope :for_season_and_birthdate, lambda {|season, birthdate|
    player_age = Player.get_age_as_of_date(birthdate, season.end_season_on)
    joins(:division).
    where("season_divisions.season_id = ? AND divisions.maximum_age >= ? AND divisions.minimum_age <= ?", season.id, player_age, player_age)
  }
  
  scope :publicly_visible, where(:hidden => false)

end