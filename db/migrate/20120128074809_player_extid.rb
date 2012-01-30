require 'digest/sha2'

class PlayerExtid < ActiveRecord::Migration
  def self.up
    add_column :players, :extid, :string
    Player.all.each do |p|
      p.update_attribute(:extid, (Digest::SHA2.new << "#{p.id}#{p.created_at.to_s}").to_s)
    end
  end

  def self.down
    remove_column :players, :extid
  end
end
