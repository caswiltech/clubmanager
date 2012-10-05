class AddParanoidDeletionToRegistrations < ActiveRecord::Migration
  def self.up
  	add_column :registrations, :deleted_at, :time
  end

  def self.down
  	drop_column :registrations, :deleted_at
  end
end
