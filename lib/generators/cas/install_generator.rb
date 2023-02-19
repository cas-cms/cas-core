module Cas
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_initializer_file
      copy_file "cas.yml", Cas::CONFIG_PATH
      route 'mount Cas::Engine, at: "/admin"'

      puts ""
      puts "Config generated. Now edit `#{Cas::CONFIG_PATH}` and run `bin/rails cas:apply_config`"
    end
  end
end
