class AddRegInit < ActiveRecord::Migration
  def self.up
    create_table :reg_inits do |t|
      t.integer :season_id
      t.date :birthdate
    end
  end
    
  def self.down
    drop_table :reg_inits
  end
end
