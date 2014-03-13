module Default
  class DbBase < ActiveRecord::Base
    establish_connection :adapter => "postgresql", :host => "localhost", :port => 5432, :username => "evercam", :database => "evercam_dev"
    self.table_name = 'vendors'
  end
end