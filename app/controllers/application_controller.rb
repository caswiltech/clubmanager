class ApplicationController < ActionController::Base
  include SslRequirement

  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  session :session_key => '_cmg_session_id'
  
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

  private
  
  def authorize
    unless User.find_by_id(session[:user_id])
      session[:original_uri] = request.request_uri
      flash[:notice] = "Please login to access ClubManager"
      redirect_to(:controller => "login", :action => "login")
    end
  end

end