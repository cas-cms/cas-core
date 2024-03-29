# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
#require File.expand_path('../../config/environment', __FILE__)
require File.expand_path('../test_app/config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rspec'
require 'capybara/rails'
require 'factory_girl_rails'
require 'database_cleaner'
require 'sidekiq/testing'

Dir[Rails.root.join('../support/**/*.rb')].each   { |f| require f }

# Checks for pending migration and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.

ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
  config.include Cas::Engine.routes.url_helpers
  config.include AcceptanceOperations
  config.include ShrineStubbing
  config.include FactoryGirl::Syntax::Methods
  config.include DeviseSupport, type: :request

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.around(:each) do |example|
    Cas::RemoteCallbacks.reset
    Capybara.app_host = 'http://example.com'
    FactoryGirl.reload
    Sidekiq::Worker.clear_all
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

def json(r = response)
  ActiveSupport::JSON.decode(r.body)
end
