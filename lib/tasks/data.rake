namespace :data do
  # desc "Refresh the data and deploy on the new cloud environment"
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
  
  task :dedupe => :environment do
    Registration.all.each do |reg|
      puts "reg.id,season.id,player.name,player.birthdate,pg1.id,pg1.name,pg1.email,pg1.alt_email,pg2.id,pg2.name,pg2.email,pg2.alt_email\n"
      
      reg_people = ",#{reg.registrations_people.first.person.id},#{reg.registrations_people.first.person.first_name} #{reg.registrations_people.first.person.last_name},#{reg.registrations_people.first.person.email},#{reg.registrations_people.first.person.alt_email}"
      if reg.registrations_people.count > 1
        reg_people << ",#{reg.registrations_people[1].person.id},#{reg.registrations_people[1].person.first_name} #{reg.registrations_people[1].person.last_name},#{reg.registrations_people[1].person.email},#{reg.registrations_people[1].person.alt_email}"
      end
      puts "#{reg.id},#{reg.season_id},#{reg.player.id},#{reg.player.person.first_name} #{reg.player.person.last_name},#{reg.player.birthdate},#{reg_people}\n"
    end
    
  end
  
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
    peopleids.each do |person|
      person = Person.find(person)
      puts "#{person.first_name} #{person.last_name}\n"
    end
    
    # peopleids.each do |person|
    #   person = Person.find(person)
    #   RegistrationMailer.rereg(person, {:bulk => true}).deliver
    # end
  end
end
