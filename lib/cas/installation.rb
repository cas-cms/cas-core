module Cas
  class Installation
    def generate_sites
      ActiveRecord::Base.transaction do

        # Ruby 3.0 comes with Psych 3, while Ruby 3.1 comes with Psych 4, which
        # has a major breaking change (diff 3.3.2 → 4.0.0).
        #
        # The new YAML loading methods (Psych 4) do not load aliases unless
        # they get the aliases: true argument.  The old YAML loading methods
        # (Psych 3) do not support the :aliases keyword.
        begin
          config = YAML.safe_load_file(filename, aliases: true)
        rescue ArgumentError
          config = YAML.load(filename)
        end

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
          updated_users = []
          superadmins_emails_or_logins.each do |email_or_login|
            user = ::Cas::User.where(
              'cas_users.email = :value OR cas_users.login = :value',
              value: email_or_login
            ).first

            if user.present?
              unless updated_users.include?(user.id)
                user.update!(sites: ::Cas::Site.all)
              end
              updated_users << user.id
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
        "config/cas.config.yml"
      end
    end
  end
end

