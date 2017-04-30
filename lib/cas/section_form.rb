module Cas
  class SectionForm

    def initialize(namesite, namesection, filename)
      @filename = filename
      @namesite = namesite
      @namesection = namesection
    end

    def has_field?(field)
      config = YAML.load_file(@filename)
      #binding.pry
      sites = config["sites"]
      site = sites[@namesite]
      section = site["sections"]
      section.find { |key, value| 
        value["name"] == @namesection 
      }[1]["fields"].include?(field.to_s)
    end
  end
end

