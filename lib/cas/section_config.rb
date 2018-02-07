module Cas
  class SectionConfig
    def initialize(section)
      @section = section
    end

    def list_order_by
      order_field = load_section_config[1]['list_order_by']
      order_field || ['created_at']
    end

    def list_fields
      fields = load_section_config[1]["list_fields"]
      fields || ['title', 'created_at']
    end

    def accessible_by_person?(person)
      roles = person.roles.map(&:to_s)
      accessible_roles = load_field["accessible_roles"]

      if accessible_roles.present?
        (accessible_roles.map(&:to_s) & roles).compact.present?
      else
        true
      end
    end

    def form_has_field?(field)
      section_fields = load_section_config[1]["fields"]

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

    def load_field
      @config ||= begin
        field = load_section_config
        (field && field[1]) || {}
      end
    end

    def load_section_config
      config = YAML.load_file(filename)
      sites = config["sites"]
      site = sites[@section.site.slug]

      if site.blank?
        raise(
          Cas::Exceptions::UndefinedSite,
          "Site #{@section.site.slug} is undefined in the #{filename} file."
        )
      end

      site["sections"].find { |key, value| key == @section.slug }
    end
  end
end

