class CleanupRegistrationColumns < ActiveRecord::Migration
  def self.up    
    remove_column :registrations, :player_school
    remove_column :registrations, :player_previous_sports_experience
    remove_column :registrations, :comments
    remove_column :registrations, :promotion_source
    remove_column :registrations, :payment_method
    remove_column :registrations, :medical_form_received
  end

  def self.down
  end
end
