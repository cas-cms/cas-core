module Cas
  class Setup
    def install
      ActiveRecord::Base.transaction do
        config = YAML.load_file(filename)

        config["sites"].each do |site_slug, site_config|
          site = ::Cas::Site.where(slug: site_slug).first_or_create
          site.update!(
            domains: site_config["domains"],
            name: site_config["name"]
          )

          site_config["sections"].each do |key, section|
            model = ::Cas::Section.where(
              slug: key,
              site_id: site.id
            ).first_or_create!(
              name: section["name"],
              section_type: section["type"],
            )

            model.update!(
              name: section["name"],
              section_type: section["type"],
            )
          end
        end

        if superadmins_emails_or_logins = config["config"]["superadmins"]
          updated_people = []
          superadmins_emails_or_logins.each do |email_or_login|
            person = ::Cas::Person.where(
              'cas_people.email = :value OR cas_people.login = :value',
              value: email_or_login
            ).first

            if person.present?
              unless updated_people.include?(person.id)
                person.update!(sites: ::Cas::Site.all)
              end
              updated_people << person.id
            end
          end
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

