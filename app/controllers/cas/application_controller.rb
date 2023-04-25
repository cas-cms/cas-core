module Cas
  class ApplicationController < ActionController::Base
    include CasDomain

    protect_from_forgery with: :exception
    before_action :authenticate_user!
    before_action :set_current_user
    before_action :set_user_sites

    private

    def set_current_user
      @current_user = current_user
    end

    def set_user_sites
      @user_sites = @current_user.sites if @current_user.present?
    end
  end
end
