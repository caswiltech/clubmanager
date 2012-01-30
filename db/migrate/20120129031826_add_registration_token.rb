class AddRegistrationToken < ActiveRecord::Migration
  def self.up
    create_table :registration_tokens do |t|
      t.integer :club_id, :null => false
      t.integer :person_id
      t.string :token
      t.datetime :expires_at
    end
    add_column :registrations, :registration_token_id, :integer
    
  end

  def self.down
    drop_column :registrations, :registration_token_id
    drop_table :registration_tokens
  end
end
