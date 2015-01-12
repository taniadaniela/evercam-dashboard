source 'https://rubygems.org'
source 'https://rails-assets.org'
ruby '2.2.0'

gem 'rails', '~> 4.2.0'

gem 'sass-rails', '~> 4.0.0'
gem 'yui-compressor'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'fog',
  require: 'fog/aws/storage'
gem 'asset_sync'

gem 'bootstrap-sass', '~> 3.3.1'
gem 'autoprefixer-rails'

gem 'rails-assets-jquery-form-validator', '~> 2.1.47'
gem 'rails-assets-videojs', '~> 4.11.3'
gem 'rails-assets-datatables', '~> 1.10.4'
gem 'rails-assets-datatables-plugins', '~> 1.0'
gem 'rails-assets-screenfull', '~> 2.0'

gem 'pg'
gem 'sequel', '= 4.10.0'
gem 'bcrypt', '~> 3.1.2'
gem 'protected_attributes'
gem 'rack-rewrite'
gem 'typhoeus'
gem 'puma'
gem 'puma_worker_killer', '~> 0.0.3'
gem 'data_uri'
gem 'geocoder'
gem 'heroku_rails_deflate'
gem 'country_select',
  github: 'stefanpenner/country_select'
gem 'devise'
gem 'ie_iframe_cookies'
gem 'heroku-api'
gem 'airbrake'
gem 'intercom-rails'

group :evercam do
  gem 'evercam_misc', '~> 0.0'
  gem 'evercam_models', '~> 0.3.9'
end
gem 'evercam', '~> 0.2.4'

group :production do
  gem 'skylight'
  gem 'rails_12factor'
  gem 'newrelic_rpm'
end

group :development do
  gem 'quiet_assets'
  gem 'spring'
  gem 'rails-footnotes', '>= 4.0.0', '<5'
  gem 'jazz_hands',
    github: 'nixme/jazz_hands',
    branch: 'bring-your-own-debugger'
  gem 'pry-byebug'
  gem 'rspec', '~> 3.1.0'
  gem 'guard-rspec', '~> 4.3.1'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'vcr'
  gem 'rspec-rails', '~> 3.1.0'
  gem 'webmock', '~> 1.17'
  gem 'poltergeist'
  gem 'simplecov'
  gem 'rack_session_access'
  gem 'selenium-webdriver'
  gem 'launchy'
end
