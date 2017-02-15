module Cas
  class Engine < ::Rails::Engine
    isolate_namespace Cas

    config.generators do |g|
      g.test_framework :rspec
    end
  end
end
