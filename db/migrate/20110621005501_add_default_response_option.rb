class AddDefaultResponseOption < ActiveRecord::Migration
  def self.up
    add_column :registration_question_response_options, :defaultresponse, :boolean, :default => false
    remove_column :registration_question_response_options, :adminonly
    add_column :registration_question_response_options, :adminonly, :boolean, :default => false
  end

  def self.down
    remove_column :registration_question_response_options, :default
  end
end
