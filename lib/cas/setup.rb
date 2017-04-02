
module Cas
  class Setup
    def initialize(filename)
      @filename = filename
    end
    def install
      config = YAML.load_file(@filename)
      config["sites"].each do |site_name, site_config|
        site = Cas::Site.where(name: site_name).first_or_create 
        
        site_config["sections"].each do |key, section|
          Cas::Section.where(
            name: section["name"],
            site_id: site.id
          ).first_or_create(
            section_type: section["type"]
          )
        end
      end
    end
  end
end

