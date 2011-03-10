class PaymentPackage < ActiveRecord::Base
  belongs_to :club
  belongs_to :season_division
  
  def self.for_season_and_division(season, division)
    sd = SeasonDivision.where(:season_id => season.id, :division_id => division.id).first
    unless sd.nil?
      pp = PaymentPackage.where(:season_division_id => sd.id, :default => true).first
    end
  end
end