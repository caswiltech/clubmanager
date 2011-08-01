class QuestionModelsConversion < ActiveRecord::Migration
  def self.up
    add_column :registration_questions, :response_optional, :boolean, :default => false
    add_column :registration_questions, :player_field, :boolean, :default => false
    remove_column :registration_question_responses, :club_id
    remove_column :registration_question_response_options, :club_id

    club = Club.first
    
    # registration.promotion_source    
    player_school = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "School", :report_label => "School", :questiontext => nil, :editable_by => 0, :response_optional => true,  :player_field => true)
    schools = ["Connaught Heights Elementary", "F.W. Howay Elementary", "Glenbrook Middle School", "Herbert Spencer Elementary", "Hume Park Elementary", "John Robson Elementary", "Lord Kelvin Elementary", "Lord Tweedsmuir Elementary", "Queen Elizabeth Elementary", "Queensborough Middle School", "Richard McBride Elementary", "New Westminster Secondary", "Community Education", "Home Learners Program", "Other - Preschool", "Other - Private", "Other - Public"]
    schools.each do |school|
      RegistrationQuestionResponseOption.create(:registration_question => player_school, :response_value => school, :defaultresponse => false, :adminonly => false)
    end
    player_school_options = player_school.registration_question_response_options.to_ary
    
    transfer = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "Was this player registered with another football club for this season or last year?", :report_label => "Transfer", :questiontext => "Players transferring from other clubs in our league need to have a release form from their previous club.", :editable_by => 0, :response_optional => false, :player_field => true)
    transfer_default = RegistrationQuestionResponseOption.create(:registration_question => transfer, :response_value => "No", :defaultresponse => true, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => transfer, :response_value => "Yes", :defaultresponse => false, :adminonly => false)
    
    photo = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "I grant permission for photos of the person being registered to be published by the RCHFC:", :report_label => "Photos", :questiontext => nil, :editable_by => 0, :response_optional => false, :player_field => true)
    photo_default = RegistrationQuestionResponseOption.create(:registration_question => photo, :response_value => "Yes", :defaultresponse => true, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => photo, :response_value => "No", :defaultresponse => false, :adminonly => false)
    
    # registration.player_previous_sports_experience
    player_previous_sports_experience = RegistrationQuestion.create(:club => club, :questiontype => "text", :page_label => "Other Sports Experience", :report_label => "Other Sports", :response_optional => true, :questiontext => nil, :editable_by => 0, :player_field => true)
    
    # registration.payment_method
    payment_method = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "The registration fee for [division] is [payment_amount_for_registration]. Please choose a payment option from the following:", :report_label => "Payment Method", :questiontext => nil, :editable_by => 0, :response_optional => false, :player_field => false)
    cheque = RegistrationQuestionResponseOption.create(:registration_question => payment_method, :response_value => "Cheque", :defaultresponse => false, :adminonly => false)
    credit_card = RegistrationQuestionResponseOption.create(:registration_question => payment_method, :response_value => "Credit Card", :defaultresponse => true, :adminonly => false)
    financial_assistance = RegistrationQuestionResponseOption.create(:registration_question => payment_method, :response_value => "Financial Assistance", :defaultresponse => false, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => payment_method, :response_value => "Other Arrangement", :defaultresponse => false, :adminonly => true)
    payment_method_options = payment_method.registration_question_response_options.to_ary
    
    # registration.promotion_source
    promotion_source = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "How did you hear about Hyacks Football?", :report_label => "Promotion Source", :questiontext => nil, :editable_by => 0, :response_optional => false, :player_field => false)
    sources = ["Returning Player","Active Living Guide Ad","Community Event","Family member of another participant","Newspaper Ad","Newspaper Article","Poster","Recommendation","School","Sign","Website","Word of mouth","Other"]
    sources.each do |source|
      RegistrationQuestionResponseOption.create(:registration_question => promotion_source, :response_value => source, :defaultresponse => false, :adminonly => false)
    end
    promotion_source_options = promotion_source.registration_question_response_options.to_ary

    # registration.comments
    comments = RegistrationQuestion.create(:club => club, :questiontype => "text", :page_label => "Comments", :report_label => "Comments", :response_optional => true, :questiontext => nil, :editable_by => 0, :player_field => false)
    


    medical_form_received = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "Medical Form Received?", :report_label => "Med Form", :questiontext => nil, :editable_by => 1, :response_optional => false, :player_field => false)
    med_default = RegistrationQuestionResponseOption.create(:registration_question => medical_form_received, :response_value => "No", :defaultresponse => true, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => medical_form_received, :response_value => "Yes", :defaultresponse => false, :adminonly => true)
    
    document = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "Proof-of-Age Documentation?", :report_label => "Age Doc", :questiontext => nil, :editable_by => 1, :response_optional => false, :player_field => false)
    document_default = RegistrationQuestionResponseOption.create(:registration_question => document, :response_value => "No", :defaultresponse => true, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => document, :response_value => "Yes", :defaultresponse => false, :adminonly => true)
    
    equipment = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "Equipment Deposit Received?", :report_label => "Eqp Dep", :questiontext => nil, :editable_by => 1, :response_optional => false, :player_field => false)
    RegistrationQuestionResponseOption.create(:registration_question => equipment, :response_value => "No", :defaultresponse => true, :adminonly => false)
    equipment_default = RegistrationQuestionResponseOption.create(:registration_question => equipment, :response_value => "Yes", :defaultresponse => false, :adminonly => true)
    
    bond = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "Volunteer Bond Received?", :report_label => "Vol Bond", :questiontext => nil, :editable_by => 1, :response_optional => false, :player_field => false)
    bond_default = RegistrationQuestionResponseOption.create(:registration_question => bond, :response_value => "No", :defaultresponse => true, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => bond, :response_value => "Yes", :defaultresponse => false, :adminonly => true)
    
    parentcontract = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "Parent Contract Received?", :report_label => "Contract", :questiontext => nil, :editable_by => 1, :response_optional => false, :player_field => false)
    parentcontract_default = RegistrationQuestionResponseOption.create(:registration_question => parentcontract, :response_value => "No", :defaultresponse => true, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => parentcontract, :response_value => "Yes", :defaultresponse => false, :adminonly => true)
    
    concussion = RegistrationQuestion.create(:club => club, :questiontype => "select", :page_label => "Concussion Form Received?", :report_label => "Conc Form", :questiontext => nil, :editable_by => 1, :response_optional => false, :player_field => false)
    concussion_default = RegistrationQuestionResponseOption.create(:registration_question => concussion, :response_value => "No", :defaultresponse => true, :adminonly => false)
    RegistrationQuestionResponseOption.create(:registration_question => concussion, :response_value => "Yes", :defaultresponse => false, :adminonly => true)
    
    game_jersey = RegistrationQuestion.create(:club => club, :questiontype => "string", :page_label => "Game Jersey", :report_label => "GJ\#", :response_optional => true, :questiontext => nil, :editable_by => 1, :player_field => false)
    
    alt_game_jersey = RegistrationQuestion.create(:club => club, :questiontype => "string", :page_label => "Alternate Jersey", :report_label => "Alt\#", :response_optional => true, :questiontext => nil, :editable_by => 1, :player_field => false)
    
    
    Registration.all.each do |reg|
      if reg.promotion_source =~ /was a member/
        # promotion_source is "Returning Player"
        promotion_source_option = promotion_source_options.find{|s| s.response_value == "Returning Player"}
      else
        promotion_source_option = promotion_source_options.find{|s| s.response_value == reg.promotion_source}
      end
      promotion_source_option_id = promotion_source_option.present? ? promotion_source_option.id : (promotion_source.response_optional? ? nil : (promotion_source_options.find{|s| s.defaultresponse} || promotion_source_options.first).id)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => promotion_source, :registration_question_response_option_id => promotion_source_option_id) unless promotion_source_option_id.nil?
    
      if reg.player_previous_sports_experience.present?
        text = reg.player_previous_sports_experience
        if text.length > 255
          text = text[0..250] << "..."
        end
        reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => player_previous_sports_experience, :textresponse => text)
      end
    
      if reg.comments.present?
        text = reg.comments
        if text.length > 255
          text = text[0..250] << "..."
        end
        reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => comments, :textresponse => text)
      end
    
      # find response option for this field
      player_school_option = player_school_options.find{|s| s.response_value == reg.player_school}
      player_school_option_id = player_school_option.present? ? player_school_option.id : (player_school.response_optional? ? nil : (player_school_options.find{|s| s.defaultresponse} || player_school_options.first).id)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => player_school, :registration_question_response_option_id => player_school_option_id) unless player_school_option_id.nil?
    
      payment_method_option = payment_method_options.find{|s| s.response_value == reg.payment_method}
      payment_method_option_id = payment_method_option.present? ? payment_method_option.id : (payment_method.response_optional? ? nil : (payment_method_options.find{|s| s.defaultresponse} || payment_method_options.first).id)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => payment_method, :registration_question_response_option_id => payment_method_option_id) unless payment_method_option_id.nil?
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => transfer, :registration_question_response_option => transfer_default)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => photo, :registration_question_response_option => photo_default)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => medical_form_received, :registration_question_response_option => med_default)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => document, :registration_question_response_option => document_default)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => equipment, :registration_question_response_option => equipment_default)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => bond, :registration_question_response_option => bond_default)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => parentcontract, :registration_question_response_option => parentcontract_default)
      reg.registration_question_responses << RegistrationQuestionResponse.create(:registration_question => concussion, :registration_question_response_option => concussion_default)
    end
  end

  def self.down
  end
end
