require 'digest/sha2'

class Player < ActiveRecord::Base
  belongs_to :person
  has_many :registrations
  accepts_nested_attributes_for :person
  
  after_create :generate_extid
  
  def club
    self.registrations.last.club
  end
  
  def club_id
    club.id
  end
  
  def generate_extid
    self.update_attribute(:extid, (Digest::SHA2.new << "#{self.id}--#{self.created_at.to_s}").to_s)
  end
  
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
	
	def legal_fname
	  self.legal_first_name.blank? ? self.person.first_name : self.legal_first_name
  end

	def legal_lname
	  self.legal_last_name.blank? ? self.person.last_name : self.legal_last_name
  end
  
  def legal_name
    "#{legal_fname} #{legal_lname}"
  end
  
  def float_age_today
    ((Date.today - self.birthdate) / 365.25).round(2)
  end
  
end