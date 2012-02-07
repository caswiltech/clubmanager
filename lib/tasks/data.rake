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
end
