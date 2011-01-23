class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :clubs do |t|
      t.primary_key :id
      t.string :name, :null => false
      t.string :abbrev
      t.string :contact_email, :null => false
      t.string :reg_notify_email, :null => false
      t.string :street1
      t.string :street2
      t.string :city
      t.string :province, :limit => 3
      t.string :country
      t.string :postalcode
      t.string :phone
      t.string :homepage_url
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :club_logos do |t|
      t.column :club_id, :integer
      t.column :name, :string
      t.column :show_inline, :boolean, :default => true
      t.column :logo_file_name, :string
      t.column :logo_content_type, :string
      t.column :logo_file_size, :integer
      t.timestamps
    end
    
    create_table :users do |t|
      t.column :first_name, :string
      t.column :last_name, :string
      t.column :email, :string
      t.column :description, :string
      t.column :username, :string
      t.column :encrypted_password, :string
      t.column :salt, :string
      t.timestamps
    end
    
    create_table :clubs_users, :id => false do |t|
      t.column :club_id, :integer
      t.column :user_id, :integer
    end
    add_index :clubs_users, [:club_id, :user_id], :unique => true
    add_index :clubs_users, :user_id, :unique => true
    
    
    create_table :seasons do |t|
      t.primary_key :id
      t.integer :club_id, :null => false
      t.string :name, :null => false
      t.boolean :default
      t.date :start_season_on
      t.date :end_season_on
      t.date :start_reg_on
      t.date :end_reg_on
      t.timestamps
    end
    
    create_table :divisions do |t|
      t.primary_key :id
      t.integer :club_id, :null => false
      t.string :name, :null => false
      t.text :description
      t.integer :minimum_age, :null => false
      t.integer :maximum_age, :null => false
      t.timestamps
    end
    
    create_table :teams do |t|
      t.integer :division_id, :null => false
      t.integer :season_id, :null => false
      t.string :name
      t.text :description
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :payment_packages do |t|
      t.integer :division_id, :null => false
      t.integer :season_id, :null => false
      t.string :name, :null => false
      t.text :description
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0 
      t.boolean :default, :default => 1
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :user_roles do |t|
      t.column :user_id, :integer, :null => false
      t.column :type, :string
      t.column :adminable_id, :integer
      t.column :adminable_type, :string
      t.timestamps
    end
    
    create_table :sessions do |t|
      t.string :session_id, :null => false
      t.text :data
      t.timestamps
    end
    add_index :sessions, :session_id
    add_index :sessions, :updated_at
    
    create_table :players do |t|
      t.integer :person_id, :null => false
      t.string :legal_first_name
      t.string :legal_last_name
      t.string :carecard
      t.date :birthdate, :null => false
      t.string :gender
      t.timestamps
    end
    
    create_table :persons do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.string :street1
      t.string :street2
      t.string :city
      t.string :province, :limit => 3
      t.string :country
      t.string :postal_code
      t.string :phone
      t.string :phone_type
      t.string :alt_phone
      t.string :alt_phone_type
      t.string :email
      t.string :email_type
      t.string :alt_email
      t.string :alt_email_type
      t.time_stamps
    end

    create_table :registrations do |t|
      t.integer :division_id, :null => false
      t.integer :season_id, :null => false
      t.integer :team_id
      t.integer :player_id, :null => false
      t.string :player_school
      t.text :player_previous_sports_experience
      t.string :payment_method
      t.string :promotion_source
      t.boolean :medical_form_received
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :registrations_persons do |t|
      t.integer :registration_id
      t.integer :person_id
      t.string :person_role
    end
    add_index :registrations_persons, [:registration_id, :person_id], :unique => true        
    
  end

  def self.down
    drop_table :clubs
    drop_table :club_logos
    drop_table :seasons
    drop_table :divisions
    drop_table :teams
    drop_table :sessions
    drop_table :payment_packages
    drop_table :users
    drop_table :clubs_users
    drop_table :user_roles
    drop_table :persons
    drop_table :players
    drop_table :registrations
    drop_table :registrations_persons
  end
end
