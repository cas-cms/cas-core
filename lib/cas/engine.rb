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

    config.active_record.primary_key = :uuid
    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
