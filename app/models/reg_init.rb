class RegInit < ActiveRecord::Base
  belongs_to :season
  after_initialize :init
  
  validates_date :birthdate, :on_or_before => lambda { Date.civil(Date.current.years_ago(Division::YOUNGEST_AGE).year, 12, 31) }

  def init
    unless self.birthdate.present?
      self.birthdate = Date.civil(Date.current.years_ago(Division::YOUNGEST_AGE).year, 1, 1)
    end
  end
end