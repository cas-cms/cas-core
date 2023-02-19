module Cas
  class Installation
    def initialize(filename: nil)
      @filename = filename
      @filename ||= begin
        if Rails.env.test?
          "spec/fixtures/cas.yml"
        else
          "config/cas.config.yml"
        end
      end

      # Ruby 3.0 comes with Psych 3, while Ruby 3.1 comes with Psych 4, which
      # has a major breaking change (diff 3.3.2 → 4.0.0).
      #
      # The new YAML loading methods (Psych 4) do not load aliases unless
      # they get the aliases: true argument.  The old YAML loading methods
      # (Psych 3) do not support the :aliases keyword.
      begin
        @config = YAML.safe_load_file(@filename, aliases: true)
      rescue NoMethodError, ArgumentError
        @config = YAML.load_file(@filename)
      end
    end

    def generate_sites
      ActiveRecord::Base.transaction do
        create_sites
        create_initial_admins
        set_superadmins
      end
    end

    private

    def create_sites
      @config["sites"].each do |site_slug, site_config|
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
    end

    def create_initial_admins
      return if @config["config"]["initial_admins"].blank?

      @config["config"]["initial_admins"].each do |item|
        ::Cas::User.where(email: item).first_or_create!(
          password: "12345678",
          name: "User",
          roles: ["admin"]
        )
      end
    end

    def set_superadmins
      return if @config["config"]["superadmins"].blank?

      updated_users = []
      @config["config"]["superadmins"].each do |email_or_login|
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
