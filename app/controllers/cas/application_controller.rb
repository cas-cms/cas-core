module Cas
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :authenticate_user!
    before_action :set_current_user
    before_action :set_domain

    private

    def set_current_user
      @current_user = current_user
    end

    def set_domain
      @domain ||= (ENV["DOMAIN"] || request.domain)

      if @domain.blank? || (ENV["DOMAIN"].blank? && @domain == "localhost")
        @domain = ::Cas::Site.first!.domains.first
      end
    end
  end
end
