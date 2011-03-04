class SeasonDivision < ActiveRecord::Base
  belongs_to :season
  belongs_to :division    
end