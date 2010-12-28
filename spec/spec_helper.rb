# Configure Rails Envinronment
ENV["RAILS_ENV"] = "test"

LOG_TO_STDOUT = false
require "spec_helpers/textmate"

def integration_test?
  $0 =~ /integration/
end

if running_in_textmate? && !integration_test?
  require 'logger'
  require 'active_support/core_ext/logger'
  require File.join(File.dirname(__FILE__),'..','lib','rails_bridge')
else
  require File.expand_path("../dummy/config/environment.rb",  __FILE__)
  require "rails/test_help"
  require "rspec/rails"

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

require "spec_helpers/rails_bridge"
require "spec_helpers/test_server"

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

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
