module FormHelper
  def remove_child_link(name, f, options = {})
    options[:class] ||= ""
    options[:class] << " remove_child"
    if f.object.new_record?
      link_to_function(name, "remove_fields(this);", options)
    else
      f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this);", options)
    end
  end

  def add_child_link(name, association, options = {})
    options[:class] ||= ""
    options[:class] << " add_child"
    options[:"data-association"] = association
    link_to(name, "javascript:void(0);", options)
  end

  def new_child_fields_template(association, options = {}, &block)
    content_id = "#{association}_fields_template".to_sym
    unless content_for?(content_id)
      template = content_tag :div, with_output_buffer(&block), :id => content_id, :style => "display: none"
      content_for(content_id, template)
    end
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