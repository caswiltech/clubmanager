class RegistrationsPeopleConversion < ActiveRecord::Migration
  def self.up
    role = PersonRole.first
    regs = Registration.all
    regs.each do |reg|
      unless reg.parent_guardian1.nil?
        rp = RegistrationsPerson.create(:person => reg.parent_guardian1, :person_role => role, :primary => true)
        reg.registrations_people << rp
      end
      unless reg.parent_guardian2.nil?
        rp = RegistrationsPerson.create(:person => reg.parent_guardian2, :person_role => role, :primary => false)
        reg.registrations_people << rp
      end
    end
    
    remove_column :registrations, :parent_guardian1
    remove_column :registrations, :parent_guardian2
  end

  def self.down
    add_column :registrations, :parent_guardian1, :integer
    add_column :registrations, :parent_guardian2, :integer
    RegistrationsPerson.destroy_all
  end
end

