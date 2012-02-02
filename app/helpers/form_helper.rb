module FormHelper
  
  def append_to_label(labeltext, appendtext, remove_trailing_whitespace = false)
    labeltext.rstrip! if remove_trailing_whitespace
    labeltext.chomp(appendtext) << appendtext
  end
  
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
  
end