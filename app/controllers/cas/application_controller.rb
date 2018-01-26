module Cas
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :authenticate_person!
    before_action :set_current_person
    before_action :set_person_sites
    before_action :set_domain
    before_action :set_site

    private

    def set_current_person
      @current_person = current_person
    end

    def set_person_sites
      @person_sites = @current_person.sites if @current_person.present?
    end

    def set_domain
      @domain ||= (ENV["DOMAIN"] || request.domain)

      if @domain.blank? || (ENV["DOMAIN"].blank? && @domain == "localhost")
        @domain = ::Cas::Site.first!.domains.first
      end
    end

    def set_site
      if params[:site_id].present?
        @site = ::Cas::Site.find_by!(slug: params[:site_id])
      else
        @site = ::Cas::Site
          .where("cas_sites.domains::text[] && '{#{@domain}}'::text[]")
          .first!
      end
    end
  end
end
