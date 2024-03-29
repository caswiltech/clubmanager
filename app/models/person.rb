class Person < ActiveRecord::Base
  has_one :player
  belongs_to :club
  has_many :registrations_people
  has_many :registrations, :through => :registrations_people
  
  before_create :cleanup_names
  before_save :cleanup_fields
    
  def full_name
    "#{self.first_name} #{self.last_name}"
  end
  
  def players
    players = []
    self.registrations.each do |reg|
      players.push(reg.player_id)
    end
    Player.find(players.compact.uniq) unless players.empty?
    # self.registrations.first.player_id
  end
  
  def find_existing(fname, lname, email, options = {})
    retval = nil
    if fname.present? && lname.present?
      whereval = {}
      if options.present?
        
      end
      if email.present?
        
      end
      retval = Person.where(:first_name => fname, :last_name => lname)
    end
    retval
  end
  
  def players_seasondivisions_eligible_for_registration_now
    regops = []
    seasons = Season.accepting_registrations_now
    self.players.each do |player|
      sds = []
      seasons.each do |season|
        sd = SeasonDivision.for_season_and_birthdate(season, player.birthdate)
        sds.push(sd.first) if sd.present?
      end
      regops.push([player, sds]) unless sds.empty?
    end
    regops
  end

  def cleanup_names
    self.first_name = self.first_name.split('-').map{|x| x.split.map{|x| x.titleize.gsub(/ /,'').split('\'').map{|x| x.titleize.gsub(/ /,'')}.join('\'')}.join(' ')}.join('-') unless self.first_name.blank?
    self.last_name = self.last_name.split('-').map{|x| x.split.map{|x| x.titleize.gsub(/ /,'').split('\'').map{|x| x.titleize.gsub(/ /,'')}.join('\'')}.join(' ')}.join('-') unless self.last_name.blank?
    self.street1 = self.street1.split('-').map{|x| x.split.map{|x| x.titleize.gsub(/ /,'').split('\'').map{|x| x.titleize.gsub(/ /,'')}.join('\'')}.join(' ')}.join('-') unless self.street1.blank?
    self.postal_code = self.postal_code.upcase.gsub(/ /,'') unless self.postal_code.blank?
    self.phone = self.phone.gsub(/\D+/,'').gsub(/([0-9]{0,3})([0-9]{3})([0-9]{4})$/,"\\1#{'-'}\\2#{'-'}\\3") unless self.phone.blank?
    self.alt_phone = self.alt_phone.gsub(/\D+/,'').gsub(/([0-9]{0,3})([0-9]{3})([0-9]{4})$/,"\\1#{'-'}\\2#{'-'}\\3") unless self.alt_phone.blank?
    self.email = self.email.downcase unless self.email.blank?
    self.alt_email = self.alt_email.downcase unless self.alt_email.blank?
  end
  
  def cleanup_fields
    if self.street2.blank?
      self.street2 = nil
    end
    if self.street1.blank?
      self.street1 = nil
      self.street2 = nil
      self.city = nil
      self.province = nil
      self.country = nil
      self.postal_code = nil
    end
    if self.phone.blank?
      self.phone = nil
      self.phone_type = nil
    end      
    if self.alt_phone.blank?
      self.alt_phone = nil
      self.alt_phone_type = nil
    end      
    if self.email.blank?
      self.email = nil
      self.email_type = nil
    end      
    if self.alt_email.blank?
      self.alt_email = nil
      self.alt_email_type = nil
    end
    true
  end

end