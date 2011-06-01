class LoginController < ApplicationController
  before_filter :authorize, :except => :login

  def login
    session[:user_id] = nil
    if request.post?
      user = User.authenticate(params[:username], params[:password])
      if user
        session[:user_id] = user.id
        uri = session[:original_uri]
        session[:original_uri] = nil
        redirect_to(uri || { :action => "index" })
      else
        flashnow[:notice] = "Invalid username/password combination"
      end
    end
  end

  def logout
    session[:user_id] = nil
    flash.now[:notice] = "You've been logged out"
    redirect_to(:action => "login")
  end

  def index
  end
end
