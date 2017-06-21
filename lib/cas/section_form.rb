module Cas
  class SectionForm

    def initialize(namesite, namesection)
      @namesite = namesite
      @namesection = namesection
    end

    def has_field?(field)
      config = YAML.load_file(filename)
      sites = config["sites"]
      site = sites[@namesite]
      section = site["sections"]
      section.find { |key, value| 
        value["name"] == @namesection 
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

