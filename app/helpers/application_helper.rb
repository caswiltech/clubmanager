module ApplicationHelper
  
  def stringfix(str)
    str.split.map{|x| x.titleize.gsub(/ /,'')}.join(' ')
  end
  
  def question_response_options(question, registration)
    options = question.registration_question_response_options.publicly_visible
    # now we do some response_value placeholder replacement
    options.each do |option|
      replace_placeholders(option.response_value, registration)
    end
    options.collect{|x| [x.response_value, x.id]}
  end
  
  def replace_placeholders(string_to_process, registration)
    unless string_to_process.nil?
      if string_to_process =~ /\[/
        string_to_process.gsub!("[first_name]", registration.player.person.first_name)
        string_to_process.gsub!("[name]", "#{registration.player.person.first_name} #{registration.player.person.last_name}")
        string_to_process.gsub!("[division]", registration.division.name)
        string_to_process.gsub!("[season]", registration.season.name)
        if string_to_process =~ /\[payment_amount_for_registration\]/
          string_to_process.gsub!("[payment_amount_for_registration]", number_to_currency(PaymentPackage.for_season_and_division(registration.season, registration.division).amount))
        end
      end
    end
    string_to_process
  end
  
end
