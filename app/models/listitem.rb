class Listitem < ActiveRecord::Base
  acts_as_list :scope => :club
end
