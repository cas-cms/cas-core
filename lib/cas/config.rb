require 'yaml'

module Cas
  class Config

    def initialize(filename: nil)
      @filename = filename
    end

    def uploads
      uploads = config["uploads"] || {}

      {
        cache_directory_prefix: uploads["cache_directory_prefix"] || "cache",
        store_directory_prefix: uploads["store_directory_prefix"] || "store"
      }
    end

    private

    def read_file
      begin
        @file ||= YAML.safe_load_file(filename, aliases: true)
      rescue ArgumentError
        @file ||= YAML.load_file(filename)
      end
    end

    def filename
      @filename ||= begin
                      if File.exists?("cas.yml")
                        "cas.yml"
                      elsif ENV['RAILS_ENV'] == 'test'
                        "spec/fixtures/cas.yml"
                      else
                        raise "cas.yml file is not defined."
                      end
      end
    end

    def config
      read_file["config"] || {}
    end
  end
end

