class CreateListitems < ActiveRecord::Migration
  def self.up
    create_table :listitems do |t|
      t.string :value
      t.string :type
      t.integer :position
      t.integer :visibility, :default => 0
      t.timestamps
    end
  end

  def self.down
    drop_table :listitems
  end
end
