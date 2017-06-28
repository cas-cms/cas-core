module Cas
  class SectionConfig
    def initialize(section)
      @section = section
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
      section.find { |key, value|
        key == @section.slug
      }[1]["fields"].include?(field.to_s)
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

