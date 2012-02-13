namespace :data do

  task :convert_payment_options => :environment do
    creditcard = PaymentOption.create(:name => "Credit Card", :defaultresponse => true)
    cheque = PaymentOption.create(:name => "Cheque")
    assistance = PaymentOption.create(:name => "Financial Assistance")
    PaymentOption.create(:name => "Payment Plan", :adminonly => true)
    other = PaymentOption.create(:name => "Other", :adminonly => true)
    question = RegistrationQuestion.where(:report_label => "Payment Method").first
    question.registration_question_response_options.each do |option|
      option.registration_question_responses.each do |r|
        if option.response_value == "Credit Card"
          r.registration.update_attribute(:payment_option, creditcard)
        elsif option.response_value == "Cheque"
          r.registration.update_attribute(:payment_option, cheque)
        elsif option.response_value == "Financial Assistance"
          r.registration.update_attribute(:payment_option, assistance)
        else
          r.registration.update_attribute(:payment_option, other)
        end
      end
    end
    question.update_attribute(:editable_by, 1)
  end
    
  # task :remove_payment_question => :environment do
  #   question = RegistrationQuestion.where(:report_label => "Payment Method").first.destroy
  # end
  
  # task :fix_person_club => :environment do
  #   club_id = Club.first.id
  #   Person.all.each do |p|
  #     p.update_attribute(:club_id, club_id)
  #   end
  # end
  
  # task :dedupe_data => :environment do
  #   puts "reg.id,season.id,player.name,player.birthdate,pg1.id,pg1.name,pg1.email,pg1.alt_email,pg2.id,pg2.name,pg2.email,pg2.alt_email\n"
  #   
  #   Registration.all.each do |reg|
  #     next if reg.player.nil? || reg.player.person.nil? || reg.registrations_people.empty? || reg.registrations_people.first.person.nil?
  #     reg_people = ",#{reg.registrations_people.first.person.id},#{reg.registrations_people.first.person.first_name} #{reg.registrations_people.first.person.last_name},#{reg.registrations_people.first.person.email},#{reg.registrations_people.first.person.alt_email}"
  #     if reg.registrations_people.count > 1 && reg.registrations_people[1].present? && reg.registrations_people[1].person.present?
  #       reg_people << ",#{reg.registrations_people[1].person.id},#{reg.registrations_people[1].person.first_name} #{reg.registrations_people[1].person.last_name},#{reg.registrations_people[1].person.email},#{reg.registrations_people[1].person.alt_email}"
  #     end
  #     puts "#{reg.id},#{reg.season_id},#{reg.player.id},#{reg.player.person.first_name} #{reg.player.person.last_name},#{reg.player.birthdate},#{reg_people}\n"
  #   end
  # end  
  # task :exec_dedupe => :environment do
  #   regs = [
  #     # [r1, r2, consolidate_player, consolidate_pgs]
  #     [166,171,false,true],
  #     [20,62,false,true],
  #     [43,136,true,true],
  #     [210,211,true,true],
  #     [53,169,false,true],
  #     [98,99,false,true],
  #     [66,181,false,true],
  #     [66,226,true,true],
  #     [66,227,true,true],
  #     [7,9,true,true],
  #     [134,193,false,true],
  #     [39,40,true,true],
  #     [39,228,true,true],
  #     [161,164,false,true],
  #     [110,111,false,true],
  #     [203,222,true,true],
  #     [89,90,false,true],
  #     [122,194,false,true],
  #     [38,221,true,true],
  #     [45,47,true,true],
  #     [100,101,false,true],
  #     [108,67,true,true]
  #     ]
  #   regs.each do |reg|
  #     r1 = Registration.find reg[0]
  #     r2 = Registration.find reg[1]
  #     next if r1.blank? || r2.blank?
  #     r2.update_attribute(:player_id, r1.player_id) if reg[2]
  #     next if !reg[3] || r1.registrations_people.empty?
  #     r2.registrations_people.destroy_all
  #     RegistrationsPerson.create(:registration_id => r2.id, :person_id => r1.registrations_people[0].person_id, :person_role_id => 1, :primary => true)
  #     if r1.registrations_people.count > 1
  #       RegistrationsPerson.create(:registration_id => r2.id, :person_id => r1.registrations_people[1].person_id, :person_role_id => 1, :primary => false)
  #     end
  #     
  #   end
  # end

  task :email_rereg_links => :environment do
    peopleids = []
    
    regs = Club.first.registrations.joins("inner join players on registrations.player_id = players.id").where("(registrations.season_id = 2 OR registrations.season_id = 3) AND players.birthdate > '1998-12-31'")    
    
    regs.each do |reg|
      # has this associated player already re-registered for 2012?
      next unless Club.first.registrations.where("season_id > 3 AND id < 240 AND player_id = ?", reg.player_id).empty?
      # skip the Kleefmans
      next if reg.player.person.last_name == "Kleefman"
      next if reg.registrations_people.empty? || reg.registrations_people.first.person.blank? || reg.registrations_people.first.person.email.blank?
      peopleids << reg.registrations_people.first.person_id
    end
    peopleids = peopleids.compact.uniq
    # peopleids.each do |person|
    #   person = Person.find(person)
    #   puts "#{person.first_name} #{person.last_name}\n"
    # end
    peopleids.each do |person|
      person = Person.find(person)
      RegistrationMailer.rereg(person, {:bulk => true}).deliver
    end
  end
end
