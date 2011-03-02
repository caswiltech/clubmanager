class User < ActiveRecord::Base
  belongs_to :club
  has_many :user_roles
end