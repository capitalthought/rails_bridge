# Configure Rails Envinronment
require "rubygems"
require "bundler/setup"
require 'tm_helper'

ENV["RAILS_ENV"] = "test"

LOG_TO_STDOUT = ENV["LOG_TO_STDOUT"]

def application_test?
  ENV['TM_FILEPATH'] =~ /integration/ || \
  ENV['TM_FILEPATH'] =~ /requests/
end

if TmHelper.running_in_textmate? && !application_test?
  require File.join(File.dirname(__FILE__),'..','lib','rails_bridge')
else
  require File.expand_path("../dummy/config/environment.rb",  __FILE__)
  require "rails/test_help"
  require "rspec/rails"
  require 'capybara/rspec'
  Capybara.app = Dummy::Application
      
  ActionMailer::Base.delivery_method = :test
  ActionMailer::Base.perform_deliveries = true
  ActionMailer::Base.default_url_options[:host] = "test.com"

  Rails.backtrace_cleaner.remove_silencers!

  # Configure capybara for integration testing
  require "capybara/rails"
  Capybara.default_driver   = :rack_test
  Capybara.default_selector = :css

  # Run any available migration
  ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)

end

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

TestServer.logger = RailsBridge::ContentBridge.logger

RSpec.configure do |config|
  # == Mock Framework
  #
  # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
  #
  # config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  config.mock_with :rspec

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  # config.use_transactional_fixtures = false
  # config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  
end
