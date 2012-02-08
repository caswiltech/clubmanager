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
    
  task :remove_payment_question => :environment do
    question = RegistrationQuestion.where(:report_label => "Payment Method").first.destroy
  end
  
  task :fix_person_club => :environment do
    club_id = Club.first.id
    Person.all.each do |p|
      p.update_attribute(:club_id, club_id)
    end
  end
  
  task :email_rereg_links => :environment do
    regids = []
    Club.first.registrations.where("(season_id = 2 OR season_id = 3) AND division_id <> 7").each do |reg|
      reg.registrations_people.parent_guardians.each do |rp|
        regids.push(rp.person.id) if rp.person.email.present?
      end 
    end
    regids = regids.compact.uniq
    puts "regids(#{regids.count}) = #{regids.inspect}"
    regids.each do |person|
      person = Person.find(person)
      psds = person.players_seasondivisions_eligible_for_registration_now
      players = []
      psds.each do |psd|
        players.push(psd[0].person.first_name)
      end
      unless players.empty?
        puts "Send #{person.first_name} an email to register #{players.to_sentence}\n"
      end
    end
  end
end
