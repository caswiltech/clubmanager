class InitialSchema < ActiveRecord::Migration
  def self.up
    create_table :clubs do |t|
      t.primary_key :id
      t.string :long_name, :null => false
      t.string :short_name, :null => false
      t.string :subdomain, :null => false
      t.string :contact_email, :null => false
      t.string :reg_notify_email, :null => false
      t.string :street1
      t.string :street2
      t.string :city
      t.string :province, :limit => 3
      t.string :country
      t.string :postal_code
      t.string :phone
      t.string :homepage_url
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :club_logos do |t|
      t.integer :club_id
      t.string :name
      t.integer :logotype, :default => 0
      t.boolean :show_inline, :default => true
      t.string :logo_file_name
      t.string :logo_content_type
      t.integer :logo_file_size
      t.timestamps
    end
    
    create_table :users do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.string :email
      t.string :description
      t.string :username, :null => false
      t.string :encrypted_password
      t.string :salt
      t.timestamps
    end
    
    create_table :clubs_users, :id => false do |t|
      t.integer :club_id
      t.integer :user_id
    end
    add_index :clubs_users, [:club_id, :user_id], :unique => true
    add_index :clubs_users, :user_id, :unique => true
    
    create_table :season_divisions do |t|
      t.integer :season_id
      t.integer :division_id
      t.boolean :hidden, :default => false
    end
    
    
    create_table :seasons do |t|
      t.integer :club_id
      t.string :name, :null => false
      t.boolean :default
      t.date :start_season_on
      t.date :end_season_on
      t.date :start_reg_on
      t.date :end_reg_on
      t.timestamps
    end
    
    create_table :divisions do |t|
      t.integer :club_id
      t.string :name, :null => false
      t.text :description
      t.integer :minimum_age, :null => false
      t.integer :maximum_age, :null => false
      t.timestamps
    end
    
    create_table :teams do |t|
      t.integer :club_id
      t.integer :season_division_id
      t.string :name
      t.text :description
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :payment_packages do |t|
      t.integer :club_id
      t.integer :season_division_id
      t.string :name, :null => false
      t.text :description
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0 
      t.boolean :default, :default => true
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :user_roles do |t|
      t.integer :user_id
      t.string :role
      t.integer :adminable_id
      t.string :adminable_type
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
      t.integer :person_id
      t.string :legal_first_name
      t.string :legal_last_name
      t.string :carecard
      t.date :birthdate, :null => false
      t.string :gender
      t.timestamps
    end
    
    create_table :people do |t|
      t.integer :club_id
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
      t.timestamps
    end
    
    create_table :person_roles do |t|
      t.integer :club_id
      t.string :role_name
      t.string :role_abbreviation
    end
    
    create_table :registrations do |t|
      t.integer :club_id
      t.integer :season_id
      t.integer :division_id
      t.integer :team_id
      t.integer :player_id
      t.integer :parent_guardian1_id
      t.integer :parent_guardian2_id
      t.string :player_school
      t.text :player_previous_sports_experience
      t.string :payment_method
      t.string :promotion_source
      t.text :comments
      t.boolean :medical_form_received
      t.boolean :deleted
      t.timestamps
    end
    
    create_table :registration_datums do |t|
      t.integer :season_division_id
      t.string :page_label
      t.string :datumtype
      t.text :datum
    end

    create_table :registrations_people do |t|
      t.integer :registration_id
      t.integer :person_id
      t.integer :person_role_id
      t.boolean :primary, :default => false
    end
    
    create_table :registration_questions do |t|
      t.integer :club_id
      t.integer :season_id
      t.integer :division_id
      t.string :questiontype
      t.string :page_label
      t.string :report_label
      t.string :questiontext
      t.integer :editable_by, :default => 0
    end
    
    create_table :registration_question_responses do |t|
      t.integer :club_id
      t.integer :registration_id
      t.integer :registration_question_id
      t.integer :registration_question_response_option_id
      t.string :textresponse
    end
    
    create_table :registration_question_response_options do |t|
      t.integer :club_id
      t.integer :registration_question_id
      t.string :response_value
      t.boolean :adminonly
    end
    
    # create_table :credit_card_payments do |t|
    #   t.integer :registration_id
    #   
    # end
  end

  def self.down
    drop_table :clubs
    drop_table :club_logos
    drop_table :seasons
    drop_table :divisions
    drop_table :season_divisions
    drop_table :teams
    drop_table :sessions
    drop_table :payment_packages
    drop_table :users
    drop_table :clubs_users
    drop_table :user_roles
    drop_table :people
    drop_table :players
    drop_table :registrations
    drop_table :registration_datums
    drop_table :registrations_people
    drop_table :registration_questions
    drop_table :registration_question_responses
    drop_table :registration_question_response_options
    drop_table :person_roles
  end
end
