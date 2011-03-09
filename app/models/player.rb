class Player < ActiveRecord::Base
  belongs_to :person
  has_many :registrations
  accepts_nested_attributes_for :person
  
  # def valid_birthdate?
  #   dt = Date.today - 1
  #   if (self.birthdate > dt)
  #     errors.add(:player_birthdate, "is invalid. This date cannot be set to today or a future date.")
  #   elsif !(self.division)
  #     errors.add(:player_birthdate, "is not a valid birthdate for any of the divisions (age-based levels) that #{season.club.name} has teams in. Either this player is too young or too old to be registered.")
  #   end
  # end

  def self.get_age_as_of_date(dob, as_of_date)
		# the following handles situations where the dob is Feb 29 and the as_of_date is not a leap year
		# the assumption being that we want to calculate one's age correctly in non-leap years by 
		# assuming that for a non-leap year the birthdate occurs on Feb 28
		dob_day = dob.day
		if !(as_of_date.leap?) && (dob.month == 2 && dob.day == 29)
		  dob_day -=1
	  end
		as_of_date.year - dob.year - ((as_of_date.month > dob.month || (as_of_date.month == dob.month && as_of_date.day >= dob_day)) ? 0 : 1)
	end
  
end