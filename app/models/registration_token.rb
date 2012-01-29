require 'digest/sha2'

class RegistrationToken < ActiveRecord::Base
  belongs_to :club
  belongs_to :person
  has_many :registrations
  
  before_create :generate_token_and_expires_at
  
  def generate_token_and_expires_at
    token_salt = ""
    if self.person_id.present?
      self.expires_at = Time.now + 15.days
      token_salt = "#{self.person_id.to_s}person-hallelujah"
    else
      self.expires_at = Time.now + 31.days
      token_salt = "#{(200+rand(54321)).to_s}global-amen"
    end
    self.token = (Digest::SHA2.new << "#{token_salt}#{self.club_id}#{self.expires_at.to_s}").to_s
    true
  end
  
  def expired?
    self.expires_at < Time.now
  end
  
  def valid_for_player?(player_extid)
    !self.expired? && Player.find_by_extid(player_extid).present? && self.club_id == Player.find_by_extid(player_extid).club_id && (self.person_id.nil? || (self.person.registrations.where(:player_id => Player.find_by_extid(player_extid).id).count > 0))
  end
  
end