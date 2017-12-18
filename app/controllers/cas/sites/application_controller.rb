module Cas
  class Sites::ApplicationController < Cas::ApplicationController
    before_action :set_site

    def set_site
      if params[:site_id].blank?
        @site = Cas::Site.where(domain: [@domain]).first
      else
        @site = Cas::Site.find(params[:site_id])
      end
    end
  end
end
