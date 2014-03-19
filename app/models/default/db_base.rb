module Default
  class DbBase < ActiveRecord::Base
    establish_connection :adapter => "postgresql",
                         :host => ActiveRecord::Base.configurations[Rails.env]['host'],
                         :port => ActiveRecord::Base.configurations[Rails.env]['port'],
                         :username => ActiveRecord::Base.configurations[Rails.env]['username'],
                         :password => ActiveRecord::Base.configurations[Rails.env]['password'],
                         :database => ActiveRecord::Base.configurations[Rails.env]['database']
    self.table_name = 'vendors'
  end
end