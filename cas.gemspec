$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "cas/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "cas"
  s.version     = Cas::VERSION
  s.authors     = ["Thayná de Oliveira"]
  s.email       = ["euthaynaeng@gmail.com"]
  s.homepage    = ""
  s.summary     = "Summary of Cas."
  s.description = "Description of Cas."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.require_paths = ["lib"]

  s.add_dependency "rails", "~> 5.0.1"
  s.add_dependency "pg"
  s.add_dependency "devise"
  s.add_dependency "sass-rails"
  s.add_dependency "jquery-rails"
  s.add_dependency 'jquery-ui-rails'
  s.add_dependency "simple_form"
  s.add_dependency "kaminari", '~> 0.17.0'
  s.add_dependency "friendly_id"
  s.add_dependency 'acts-as-taggable-on'
  s.add_dependency "select2-rails"
  s.add_dependency "tinymce-rails"
  s.add_dependency 'tinymce-rails-langs'
  s.add_dependency 'sidekiq'

  # File uploads
  s.add_dependency 'shrine' # for uploading files
  s.add_dependency 'roda' # for shrine
  s.add_dependency "aws-sdk", "~> 2.1" # for file uploads

  s.add_development_dependency "awesome_print"
  s.add_development_dependency "sqlite3"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "poltergeist"
  s.add_development_dependency "capybara"
  s.add_development_dependency "pry-rails"
  s.add_development_dependency 'factory_girl_rails', '~> 4.0'
  s.add_development_dependency 'launchy'
  s.add_development_dependency 'dotenv-rails'
end
