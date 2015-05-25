# Load the Rails application.
require File.expand_path('../application', __FILE__)

Rails.logger = Logger.new(STDOUT)

# Initialize the Rails application.
EvercamDashboard::Application.initialize!
Mime::Type.register "application/pdf", :pdf
