require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)
require "cas"
require 'dotenv-rails'
require "sprockets/railtie"
Dotenv::Railtie.load

module TestApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.active_record.yaml_column_permitted_classes = [
      Symbol,
      ActiveSupport::HashWithIndifferentAccess,
      ActionController::Parameters
    ]
  end
end
