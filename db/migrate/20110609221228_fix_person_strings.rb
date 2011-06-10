class FixPersonStrings < ActiveRecord::Migration
  def self.up
    Registration.all.each do |reg|
      persons = []
      persons << reg.player.person
      persons << reg.parent_guardian1 unless reg.parent_guardian1.nil?
      persons << reg.parent_guardian2 unless reg.parent_guardian2.nil?
      persons.each do |person|
        person.first_name = person.first_name.split('-').map{|x| x.split.map{|x| x.titleize.gsub(/ /,'').split('\'').map{|x| x.titleize.gsub(/ /,'')}.join('\'')}.join(' ')}.join('-') unless person.first_name.blank?
        person.last_name = person.last_name.split('-').map{|x| x.split.map{|x| x.titleize.gsub(/ /,'').split('\'').map{|x| x.titleize.gsub(/ /,'')}.join('\'')}.join(' ')}.join('-') unless person.last_name.blank?
        person.street1 = person.street1.split('-').map{|x| x.split.map{|x| x.titleize.gsub(/ /,'').split('\'').map{|x| x.titleize.gsub(/ /,'')}.join('\'')}.join(' ')}.join('-') unless person.street1.blank?
        person.postal_code = person.postal_code.upcase.gsub(/ /,'') unless person.postal_code.blank?
        person.phone = person.phone.gsub(/\D+/,'').gsub(/([0-9]{0,3})([0-9]{3})([0-9]{4})$/,"\\1#{'-'}\\2#{'-'}\\3") unless person.phone.blank?
        person.alt_phone = person.alt_phone.gsub(/\D+/,'').gsub(/([0-9]{0,3})([0-9]{3})([0-9]{4})$/,"\\1#{'-'}\\2#{'-'}\\3") unless person.alt_phone.blank?
        person.email = person.email.downcase unless person.email.blank?
        person.alt_email = person.alt_email.downcase unless person.alt_email.blank?
        person.save
      end
    end
  end

  def self.down
  end
end
