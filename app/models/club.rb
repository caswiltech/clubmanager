class Club < ActiveRecord::Base
  validates_presence_of :long_name, :short_name, :subdomain, :contact_email, :reg_notify_email
  # validates_format_of :image_url, :with => %r{\.(gif|jpg|jpeg|png)$}i, :message => "must be a URL for a GIF, JPG or PNG image."
  has_many :club_logos
  # has_and_belongs_to_many :users
  has_many :user_roles, :dependent => :destroy
  has_many :seasons, :dependent => :destroy
  has_many :divisions, :dependent => :destroy
  has_many :season_divisions, :through => :seasons
  has_many :registrations, :dependent => :destroy
  has_many :registration_datums, :dependent => :destroy
  has_many :registration_questions, :dependent => :destroy
  has_many :registration_question_response_options, :dependent => :destroy
  has_many :payment_packages, :dependent => :destroy
  has_many :players, :dependent => :destroy
  has_many :people, :dependent => :destroy
  has_many :person_roles, :dependent => :destroy
  has_many :roles, :as => :adminable, :dependent => :destroy
  has_many :quit_reasons
  
  def self.find_clubs_for_sysadmin
    find(:all, :order => 'name')
  end
    
  def teams
    Team.where("season_division_id IN (?)", self.season_division_ids)
  end

end
