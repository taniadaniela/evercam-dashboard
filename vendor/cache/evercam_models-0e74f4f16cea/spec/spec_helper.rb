# Add to include paths.
$: << "#{Dir.getwd}/spec"

ENV['EVERCAM_ENV'] ||= 'test'

require 'bundler'
require 'database_cleaner'
require 'evercam_misc'
require 'matchers'
require 'sequel'

# Establish database connection.
db = Sequel.connect(Evercam::Config[:database])

Bundler.require(:default, :test)

# code coverage
SimpleCov.start do
  add_filter '/spec/'
end

RSpec.configure do |c|
  c.expect_with :stdlib, :rspec
  c.filter_run :focus => true
  c.filter_run_excluding skip: true
  c.run_all_when_everything_filtered = true
  c.mock_framework = :mocha
  c.fail_fast = true if ENV['FAIL_FAST']

  c.after(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  c.before :each do
    Typhoeus::Expectation.clear
  end
end

# Stubbed requests
require 'webmock/rspec'

