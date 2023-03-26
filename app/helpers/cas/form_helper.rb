module Cas
  module FormHelper
    def display_field?(name)
      ::Cas::SectionConfig.new(@section).form_has_field?(name)
    end

    def form_associations
      ::Cas::SectionConfig.new(@section).form_associations
    end

    def field_properties(name)
      ::Cas::FormField.new(@section, name)
    end
  end
end
