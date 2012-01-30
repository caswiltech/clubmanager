require 'digest/sha2'

class User < ActiveRecord::Base
  has_many :user_roles
  
  validates :username, :presence => true, :uniqueness => true
  validates :first_name, :last_name, :presence => true
  validates :password, :confirmation => true
  
  attr_accessor :password_confirmation
  attr_reader :password
  validate :password_must_be_present
  
  class << self
    def authenticate(username, password)
      if user = find_by_username(username)
        if user.encrypted_password == encrypt_password(password, user.salt)
          user
        end
      end
    end
    
    def encrypt_password(password, salt)
      Digest::SHA2.hexdigest(password + "hyacks" + salt)
    end
  end
  
  def password=(password)
    @password = password
    if password.present?
      self.salt = generate_salt
      self.encrypted_password = self.class.encrypt_password(password, salt)
    end
  end
  
  private
  def password_must_be_present
    errors.add(:password, "Missing password") unless encrypted_password.present?
  end
  
  
  def generate_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
end