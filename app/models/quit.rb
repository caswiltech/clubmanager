class Quit < ActiveRecord::Base
  has_one :registration
  belongs_to :quit_reason
end
