class CreateQuits < ActiveRecord::Migration
  def self.up
    create_table :quits do |t|
    	t.integer :quit_reason_id
    	t.string :notes
      t.timestamps
    end

    add_column :registrations, :quit_id, :integer
  end

  def self.down
    drop_table :quits
    remove_column :registrations, :quit_id
  end
end
