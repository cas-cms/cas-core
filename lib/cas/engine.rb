module Cas
  class Engine < ::Rails::Engine
    isolate_namespace Cas

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    config.after_initialize do
      Dir.glob("#{config.root}/app/uploaders/**/*.rb").each do |c|
        require_dependency(c)
      end
    end

    config.assets.precompile += [
      "cas/application.css",
      "cas/application.js",
      "cas/fileupload_manifest.js"
    ]

    config.active_record.primary_key = :uuid
    config.generators do |g|
      g.test_framework :rspec
    end

    def self.mounted_path
      route = Rails.application.routes.routes.detect do |current_route|
        current_route.app == self
      end
      route && route.path
    end
  end
end
