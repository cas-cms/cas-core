require "cas/engine"
require "cas/exceptions"
require "cas/config"
require "cas/remote_callbacks"
require "cas/installation"
require "cas/section_config"
require "cas/form_field"

require 'devise'
require 'simple_form'
require 'friendly_id'
require 'jquery-rails'
require 'jquery-ui-rails'
require 'kaminari'
require 'acts-as-taggable-on'
require 'tinymce-rails'
require 'tinymce-rails-langs'
require 'shrine'
require 'sidekiq'
require 'pg_search'

module Cas
  CONFIG_PATH = "config/cas.config.yml"
end
