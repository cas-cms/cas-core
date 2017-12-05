module Cas
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    before_action :authenticate_user!
    before_action :set_current_user

    private

    def set_current_user
      @current_user = current_user
    end

    def set_domain
      @domain ||= (ENV["DOMAIN"] || request.domain)
    end
  end
end
