class ApplicationController < ActionController::Base
  include SslRequirement
  
  def ssl_required?
    ENV['RAILS_ENV'] == 'development' ? false : true
  end
  
  def render_csv(filename = nil)
    filename ||= params[:action]
    filename += '.csv'
    
    Rails::logger.info "\n\n#{'x'*50}\n\n"
    Rails::logger.info "\n\nin render_csv method, filename = #{filename}\n\n"
    

    if request.env['HTTP_USER_AGENT'] =~ /msie/i
      headers['Pragma'] = 'public'
      headers["Content-type"] = "text/plain" 
      headers['Cache-Control'] = 'no-cache, must-revalidate, post-check=0, pre-check=0'
      headers['Content-Disposition'] = "attachment; filename=\"#{filename}\"" 
      headers['Expires'] = "0" 
    else
      headers["Content-Type"] ||= 'text/csv'
      headers["Content-Disposition"] = "attachment; filename=\"#{filename}\"" 
    end

    render :layout => false
  end
end
