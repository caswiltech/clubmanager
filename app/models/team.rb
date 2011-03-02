class Team < ActiveRecord::Base
  belongs_to :club
  belongs_to :season
  belongs_to :division
  has_many :user_roles, :as => :assignee, :dependent => :destroy
  has_many :registrations
end