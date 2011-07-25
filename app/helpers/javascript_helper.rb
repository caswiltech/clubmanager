module JavascriptHelper

  # the javascript block will be placed inside a jQuery(document).ready function
  def jquery_init(*args, &block)
    @__jquery_init ||= "".html_safe
    content, options = extract_content_and_options(*args, &block)
    add_content(@__jquery_init, content, options)
  end

  # the javascript block will be called after all the scripts have loaded
  def javascript_init(*args, &block)
    @__javascript_init ||= "".html_safe
    content, options = extract_content_and_options(*args, &block)
    add_content(@__javascript_init, content, options)
  end

  # You can LazyLoad more scripts through this method
  def javascript_content(*args, &block)
    @__javascript_content ||= "".html_safe
    content, options = extract_content_and_options(*args, &block)
    add_content(@__javascript_content, content, options)
  end

  # returns content and options
  def extract_content_and_options(*args, &block)
    options = args.extract_options!

    content = args.first || ""
    content = capture(&block) if block_given?

    [remove_script_and_cdata_tags(content), options]
  end

  # this should be the last method called as it returns a string to be properly returned into the page
  def add_content(target, content, options)
    if options[:force] || request.xhr? || in_iframe_ajax?
      javascript_tag(content)
    else
      target << content
      ""
    end
  end

  def remove_script_and_cdata_tags(content)
    content.gsub(/^\s*<script[^>]*>(\s*\/\*\s*<!\[CDATA\[\s*\*\/)?/, "").gsub(/(\s*\/\*\s*\]\]\>\s*\*\/)?\s*<\/script>\s*$/, "").html_safe
  end
end
