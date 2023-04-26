module Cas
  module FormHelper
    def display_field?(name)
      raise "No @section defined" if @section.blank?
      ::Cas::SectionConfig.new(@section).form_has_field?(name)
    end

    def form_associations
      raise "No @section defined" if @section.blank?
      @form_associations ||= ::Cas::SectionConfig.new(@section).form_associations
    end

    def autocomplete_for_has_many
      form_associations.each_with_object([]) { |association, memo|
        slug = association.field_name
        section = Cas::Section.where(slug: slug).pluck(:id, :name).first

        Cas::Content.where(section_id: section[0]).pluck(:id, :title).each do |content|
          memo << { value: content[0], text: "#{content[1]} (#{section[1]})" }
        end
      }
    end

    def field_properties(name)
      raise "No @section defined" if @section.blank?
      ::Cas::FormField.new(@section, name)
    end
  end
end
