class AddHyacksTeams < ActiveRecord::Migration
  def self.up
    remove_column :teams, :club_id
    football_season = Season.find_by_name("2011 Summer/Fall Football")
    cheer_season = Season.find_by_name("2011 Cheerleading")
    flag_div = Division.find_by_name("Flag Football")
    atom_div = Division.find_by_name("Atom Football")
    peewee_div = Division.find_by_name("Peewee Football")
    jb_div = Division.find_by_name("Junior Bantam Football")
    cheer_div = Division.find_by_name("Junior Cheerleading")
    flag_sd = SeasonDivision.find_by_season_id_and_division_id(football_season.id, flag_div.id)
    atom_sd = SeasonDivision.find_by_season_id_and_division_id(football_season.id, atom_div.id)
    peewee_sd = SeasonDivision.find_by_season_id_and_division_id(football_season.id, peewee_div.id)
    jb_sd = SeasonDivision.find_by_season_id_and_division_id(football_season.id, jb_div.id)
    cheer_sd = SeasonDivision.find_by_season_id_and_division_id(cheer_season.id, cheer_div.id)
    flag = Team.create(:season_division_id => flag_sd.id, :name => "Hyacks").id
    atom = Team.create(:season_division_id => atom_sd.id, :name => "Hyacks Black").id
    atom2 = Team.create(:season_division_id => atom_sd.id, :name => "Hyacks Orange")
    peewee = Team.create(:season_division_id => peewee_sd.id, :name => "Hyacks").id
    jb = Team.create(:season_division_id => jb_sd.id, :name => "Hyacks").id
    cheer = Team.create(:season_division_id => cheer_sd.id, :name => "Hyacks").id
    
    flag_sd.registrations.each do |reg|
      reg.update_attribute(:team_id, flag)
    end
    atom_sd.registrations.each do |reg|
      reg.update_attribute(:team_id, atom)
    end
    peewee_sd.registrations.each do |reg|
      reg.update_attribute(:team_id, peewee)
    end
    jb_sd.registrations.each do |reg|
      reg.update_attribute(:team_id, jb)
    end
    cheer_sd.registrations.each do |reg|
      reg.update_attribute(:team_id, cheer)
    end
    
  end

  def self.down
  end
end
