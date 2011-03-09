class ApplicationController < ActionController::Base
  include SslRequirement
  
  def ssl_required?
    ENV['RAILS_ENV'] == 'development' ? false : true
  end
end
