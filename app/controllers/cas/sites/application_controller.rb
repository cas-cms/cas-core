class Cas::Sites::ApplicationController < ::Cas::ApplicationController
  before_action :set_site

  private

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
