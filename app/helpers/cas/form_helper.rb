module Cas
  module FormHelper
    def display_field?(name)
      ::Cas::SectionConfig.new(@section).form_has_field?(name)
    end

    def field_properties(name)
      ::Cas::FormField.new(@section, name)
    end

    # simple_form options for a date or datetime field configured in cas.yml.
    # `format` lists the selects in order; including `hour` makes it a datetime
    # input. `start_year` widens the year select, which Rails otherwise limits
    # to five years around the stored (or current) year. `value` is the date
    # already stored, so the range always contains it.
    def date_input_options(name, value = nil)
      field = field_properties(name)
      options = { as: date_input_type(field), order: field.format }
      options.merge!(year_range_options(field, value)) if field.start_year
      options
    end

    private

    def date_input_type(field)
      field.format.include?(:hour) ? :datetime : :date
    end

    # Rails drops a stored year that falls outside start_year..end_year and
    # saves the first option instead, so the stored year is always included.
    # The range ends at the current year: later years would let a mis-click
    # date an item into the future.
    def year_range_options(field, value)
      years = [field.start_year, Date.current.year, value && value.year].compact
      { start_year: years.min, end_year: years.max }
    end
  end
end
