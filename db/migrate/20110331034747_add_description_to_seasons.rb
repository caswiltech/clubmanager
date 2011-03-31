class AddDescriptionToSeasons < ActiveRecord::Migration
  def self.up
    add_column :seasons, :description, :text
  end

  def self.down
    drop_column :seasons, :description
  end
end
