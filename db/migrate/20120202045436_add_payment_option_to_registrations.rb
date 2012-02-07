class AddPaymentOptionToRegistrations < ActiveRecord::Migration
  def self.up
      create_table :payment_options do |t|
        t.string :name, :null => false
        t.boolean :adminonly, :default => false
        t.boolean :defaultresponse, :default => false
      end
      add_column :registrations, :payment_option_id, :integer
      
    end

    def self.down
      remove_column :registrations, :payment_option_id
      drop_table :payment_options
    end
end
