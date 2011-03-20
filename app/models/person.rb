class Person < ActiveRecord::Base
  has_one :player
  belongs_to :club
  has_many :registrations, :class_name => 'Registration', :foreign_key => 'parent_guardian1_id'
  has_many :registrations, :class_name => 'Registration', :foreign_key => 'parent_guardian2_id'
  
  # validates :first_name, :last_name, :presence => true
  
  before_save :cleanup_fields
  
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