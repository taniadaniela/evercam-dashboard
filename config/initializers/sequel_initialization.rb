# Sequel library and model initialization. Lift from...
# http://rosenfeld.herokuapp.com/en/articles/2012-04-18-getting-started-with-sequel-in-rails

require 'evercam_misc'

configuration = ActiveRecord::Base.configurations[Rails.env]
configuration['adapter'] = 'postgres' if configuration['adapter'] == 'postgresql'
configuration['user']    = configuration.delete 'username'
configuration['logger']  = [Logger.new("log/#{Rails.env}_db.log")]
configuration['logger'] << Logger.new(STDOUT) if Rails.env.development?
DB = Sequel::Model.db = Sequel.connect(configuration)
Sequel::Model.db.sql_log_level = Rails.application.config.log_level || :debug

if ARGV.any? {|parameter| parameter =~ /(--sandbox|-s)/}
   # Do everything inside a transaction when using rails c --sandbox (or -s).
   DB.pool.after_connect = proc do |connection|
      DB.send(:add_transaction, connection, {})
      DB.send(:begin_transaction, connection, {})
   end
end

# Connection created, pull in the model classes.
require 'evercam_models'
