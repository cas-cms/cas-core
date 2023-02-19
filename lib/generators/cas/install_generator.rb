module Cas
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_initializer_file
      copy_file "cas.yml", "config/cas.config.yml"


      rails_command("cas:generate_sites")
    end
  end
end
