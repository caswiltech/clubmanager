# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)
run Cmg::Application

Cmg::Application.config.middleware.use ExceptionNotifier,
  :email_prefix => "ERROR: ",
  :sender_address => %{"Clubmanager Errors" <info@hyackfootball.com>},
  :exception_recipients => %w{rleslie@hyackfootball.com}
