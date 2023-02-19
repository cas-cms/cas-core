module Cas
  class FormField
    def initialize(section, field_name)
      @section = section
      @field_name = field_name
    end

    def method_missing(name, *args, &block)
      load_field[name]
    end

    private

    def filename
      if Rails.env.test?
        "spec/fixtures/cas.yml"
      else
        Cas::CONFIG_PATH
      end
    end

    def load_field
      @config ||= begin
        begin
          config_file = YAML.safe_load_file(filename, aliases: true)
        rescue NoMethodError, ArgumentError
          config_file = YAML.load_file(filename)
        end
        sites = config_file["sites"]
        site = sites[@section.site.slug]
        section = site["sections"]
        fields = section.find { |key, value|
          key == @section.slug
        }[1]["fields"]

        config = fields.find do |field|
          if field.is_a?(Hash)
            field[@field_name.to_s]
          else
            field == @field_name.to_s
          end
        end

        if config.is_a?(Hash)
          config = config[@field_name.to_s]
          config = config.deep_symbolize_keys
        else
          config = {}
        end

        config.merge(
          format: (config[:format] || [:day, :month, :year]).map(&:to_sym)
        )
      end
    end
  end
end

