
module Cas
  class Setup
    def install
      config = YAML.load_file(filename)
      config["sites"].each do |site_slug, site_config|
        site = ::Cas::Site.where(slug: site_slug).first_or_create

        site_config["sections"].each do |key, section|
          ::Cas::Section.where(
            slug: key,
            site_id: site.id
          ).first_or_create!(
            name: section["name"],
            section_type: section["type"]
          )
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
  end
end

