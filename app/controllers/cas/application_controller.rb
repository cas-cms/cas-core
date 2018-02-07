module Cas
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :authenticate_user!
    before_action :set_current_user
    before_action :set_person_sites
    before_action :set_domain
    before_action :set_site

    private

    def set_current_user
      @current_user = current_user
    end

    def set_person_sites
      @person_sites = @current_user.sites if @current_user.present?
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
