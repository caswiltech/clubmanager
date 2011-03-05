class ApplicationController < ActionController::Base
  include SslRequirement
  
  def ssl_required?
    true
  end
end
