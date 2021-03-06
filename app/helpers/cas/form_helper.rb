module Cas
  module FormHelper
    def display_field?(name)
      ::Cas::SectionConfig.new(@section).form_has_field?(name)
    end

    def field_properties(name)
      ::Cas::FormField.new(@section, name)
    end
  end
end
