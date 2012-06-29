# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120613041511) do

  create_table "active_admin_comments", :force => true do |t|
    t.integer  "resource_id",   :null => false
    t.string   "resource_type", :null => false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], :name => "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], :name => "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], :name => "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",     :limit => 128, :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admin_users", ["email"], :name => "index_admin_users_on_email", :unique => true
  add_index "admin_users", ["reset_password_token"], :name => "index_admin_users_on_reset_password_token", :unique => true

  create_table "club_logos", :force => true do |t|
    t.integer   "club_id"
    t.string    "name"
    t.integer   "logotype",          :default => 0
    t.boolean   "show_inline",       :default => true
    t.string    "logo_file_name"
    t.string    "logo_content_type"
    t.integer   "logo_file_size"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "clubs", :force => true do |t|
    t.string    "long_name",                     :null => false
    t.string    "short_name",                    :null => false
    t.string    "subdomain",                     :null => false
    t.string    "contact_email",                 :null => false
    t.string    "reg_notify_email",              :null => false
    t.string    "street1"
    t.string    "street2"
    t.string    "city"
    t.string    "province",         :limit => 3
    t.string    "country"
    t.string    "postal_code"
    t.string    "phone"
    t.string    "homepage_url"
    t.boolean   "deleted"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "clubs_users", :id => false, :force => true do |t|
    t.integer "club_id"
    t.integer "user_id"
  end

  add_index "clubs_users", ["club_id", "user_id"], :name => "index_clubs_users_on_club_id_and_user_id", :unique => true
  add_index "clubs_users", ["user_id"], :name => "index_clubs_users_on_user_id", :unique => true

  create_table "divisions", :force => true do |t|
    t.integer   "club_id"
    t.string    "name",        :null => false
    t.text      "description"
    t.integer   "minimum_age", :null => false
    t.integer   "maximum_age", :null => false
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "payment_options", :force => true do |t|
    t.string  "name",                               :null => false
    t.boolean "adminonly",       :default => false
    t.boolean "defaultresponse", :default => false
  end

  create_table "payment_packages", :force => true do |t|
    t.integer   "club_id"
    t.integer   "season_division_id"
    t.string    "name",                                 :null => false
    t.text      "description"
    t.decimal   "amount",             :default => 0.0
    t.boolean   "default",            :default => true
    t.boolean   "deleted"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "people", :force => true do |t|
    t.integer   "club_id"
    t.string    "first_name",                  :null => false
    t.string    "last_name",                   :null => false
    t.string    "street1"
    t.string    "street2"
    t.string    "city"
    t.string    "province",       :limit => 3
    t.string    "country"
    t.string    "postal_code"
    t.string    "phone"
    t.string    "phone_type"
    t.string    "alt_phone"
    t.string    "alt_phone_type"
    t.string    "email"
    t.string    "email_type"
    t.string    "alt_email"
    t.string    "alt_email_type"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "person_roles", :force => true do |t|
    t.integer "club_id"
    t.string  "role_name"
    t.string  "role_abbreviation"
  end

  create_table "players", :force => true do |t|
    t.integer   "person_id"
    t.string    "legal_first_name"
    t.string    "legal_last_name"
    t.string    "carecard"
    t.date      "birthdate",        :null => false
    t.string    "gender"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.string    "extid"
  end

  create_table "reg_inits", :force => true do |t|
    t.integer "season_id"
    t.date    "birthdate"
  end

  create_table "registration_datums", :force => true do |t|
    t.integer "season_division_id"
    t.string  "page_label"
    t.string  "datumtype"
    t.text    "datum"
  end

  create_table "registration_question_response_options", :force => true do |t|
    t.integer "registration_question_id"
    t.string  "response_value"
    t.boolean "defaultresponse",          :default => false
    t.boolean "adminonly",                :default => false
  end

  create_table "registration_question_responses", :force => true do |t|
    t.integer "registration_id"
    t.integer "registration_question_id"
    t.integer "registration_question_response_option_id"
    t.string  "textresponse"
  end

  create_table "registration_questions", :force => true do |t|
    t.integer "club_id"
    t.integer "season_id"
    t.integer "division_id"
    t.string  "questiontype"
    t.string  "page_label"
    t.string  "report_label"
    t.string  "questiontext"
    t.integer "editable_by",       :default => 0
    t.boolean "response_optional", :default => false
    t.boolean "player_field",      :default => false
  end

  create_table "registration_tokens", :force => true do |t|
    t.integer   "club_id",    :null => false
    t.integer   "person_id"
    t.string    "token"
    t.timestamp "expires_at"
  end

  create_table "registrations", :force => true do |t|
    t.integer   "club_id"
    t.integer   "season_id"
    t.integer   "division_id"
    t.integer   "team_id"
    t.integer   "player_id"
    t.integer   "parent_guardian1_id"
    t.integer   "parent_guardian2_id"
    t.boolean   "deleted"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.integer   "registration_token_id"
    t.integer   "payment_option_id"
  end

  create_table "registrations_people", :force => true do |t|
    t.integer "registration_id"
    t.integer "person_id"
    t.integer "person_role_id"
    t.boolean "primary",         :default => false
  end

  create_table "season_divisions", :force => true do |t|
    t.integer "season_id"
    t.integer "division_id"
    t.boolean "hidden",      :default => false
  end

  create_table "seasons", :force => true do |t|
    t.integer   "club_id"
    t.string    "name",            :null => false
    t.boolean   "default"
    t.date      "start_season_on"
    t.date      "end_season_on"
    t.date      "start_reg_on"
    t.date      "end_reg_on"
    t.timestamp "created_at"
    t.timestamp "updated_at"
    t.text      "description"
  end

  create_table "sessions", :force => true do |t|
    t.string    "session_id", :null => false
    t.text      "data"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "teams", :force => true do |t|
    t.integer   "season_division_id"
    t.string    "name"
    t.text      "description"
    t.boolean   "deleted"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "user_roles", :force => true do |t|
    t.integer   "user_id"
    t.string    "role"
    t.integer   "adminable_id"
    t.string    "adminable_type"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string    "first_name",         :null => false
    t.string    "last_name",          :null => false
    t.string    "email"
    t.string    "description"
    t.string    "username",           :null => false
    t.string    "encrypted_password"
    t.string    "salt"
    t.timestamp "created_at"
    t.timestamp "updated_at"
  end

end
