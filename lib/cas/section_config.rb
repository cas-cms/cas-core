module Cas
  class SectionConfig
    def initialize(section)
      @section = section
    end

    def list_order_by
      config = YAML.load_file(filename)
      sites = config["sites"]
      site = sites[@section.site.slug]
      section = site["sections"]

      order_field = section.find { |key, value|
        key == @section.slug
      }[1]['list_order_by']

      order_field || ['created_at']
    end

    def list_fields
      config = YAML.load_file(filename)
      sites = config["sites"]
      site = sites[@section.site.slug]
      section = site["sections"]
      fields = section.find { |key, value|
        key == @section.slug
      }[1]["list_fields"]
      fields || ['title', 'created_at']
    end

    def form_has_field?(field)
      config = YAML.load_file(filename)
      sites = config["sites"]
      site = sites[@section.site.slug]
      section = site["sections"]
      section_fields = section.find { |key, value|
        key == @section.slug
      }[1]["fields"]

      Array.wrap(section_fields).any? do |section_field|
        if section_field.is_a?(Hash)
          section_field.keys.map(&:to_s).include?(field.to_s)
        else
          section_field.to_s == field.to_s
        end
      end
    end

    private

    def filename
      if Rails.env.test?
        "spec/fixtures/cas.yml"
      else
        "cas.yml"
      end
    end
  end
end

