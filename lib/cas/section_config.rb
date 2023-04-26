module Cas
  # When updating this class, please update docs/config.md
  #
  # The section config has a format like the following:
  #
  #   news:
  #     name: "Today's News"
  #     type: content
  #     has_many:
  #       - teams
  #     list_fields:
  #       - title
  #       - category
  #     fields:
  #       - category
  #       - tags
  #       - title
  #       - teams:
  #           key: value
  #       - summary
  #       - text
  #       - images
  #       - files
  #       - tags
  #       - date
  #
  # To get a particular field, you can call
  #
  #   fields = load_section_config[1]["list_fields"]
  #
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

    def accessible_by_user?(user)
      roles = user.roles.map(&:to_s)
      accessible_roles = load_field["accessible_roles"]

      if accessible_roles.present?
        (accessible_roles.map(&:to_s) & roles).compact.present?
      else
        true
      end
    end

    def form_has_field?(field)
      form_fields.any? do |section_field|
        if section_field.is_a?(Hash)
          section_field.keys.map(&:to_s).include?(field.to_s)
        else
          section_field.to_s == field.to_s
        end
      end
    end

    def form_associations
      form_fields
        .select { |field|
          field_name = if field.is_a?(Hash)
                         field.keys.first
                       else
                         field
                       end

          associations.include?(field_name.to_s)
        }
        .map { |association|
          Cas::SectionAssociation.new(association)
        }
    end

    private

    def form_fields
      @form_fields ||= Array.wrap(load_section_config[1]["fields"])
    end

    def filename
      if Rails.env.test?
        "spec/fixtures/cas.yml"
      else
        Cas::CONFIG_PATH
      end
    end

    def associations
      @associations ||= Array.wrap(load_section_config[1]["has_many"])
    end

    def load_field
      @config ||= begin
        field = load_section_config
        (field && field[1]) || {}
      end
    end

    def load_section_config
      begin
        config = YAML.safe_load_file(filename, aliases: true)
      rescue NoMethodError, ArgumentError
        config = YAML.load_file(filename)
      end

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

