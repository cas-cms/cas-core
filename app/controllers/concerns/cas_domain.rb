module CasDomain
  extend ActiveSupport::Concern

  included do
    before_action :set_domain
    before_action :set_site
  end

  def set_domain
    @domain ||= (ENV["DOMAIN"] || request.domain)

    if @domain.blank? || (ENV["DOMAIN"].blank? && @domain == "localhost")
      @domain = ::Cas::Site.first!.domains.first
    end
  rescue ActiveRecord::RecordNotFound => e
    raise Cas::Exceptions::IncompleteSetup, "IncompleteSetup: check README.md. #{e.message}: #{e.inspect}"
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
