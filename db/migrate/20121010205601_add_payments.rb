class AddPayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.integer :club_id
      t.integer :registration_id
      t.integer :payment_option_id
      t.integer :user_id
      t.integer :amount, :default => 0
      t.string :paid_by
      t.string :admin_note
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
