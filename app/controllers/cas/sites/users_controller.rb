require_dependency "cas/application_controller"

module Cas
  class Sites::UsersController < Sites::ApplicationController
    def index
      @users = @site.users.order('name ASC')
    end

    def new
      @user = ::Cas::User.new
      get_selected_sites
    end

    def create
      @user = ::Cas::User.new(user_params)
      @user.roles = user_params[:roles]
      @user.site_ids = user_params[:site_ids]
      if @user.save
        redirect_to site_users_url(@site)
      else
        get_selected_sites
        render :new
      end
    end

    def edit
      @user = ::Cas::User.find(params[:id])
      get_selected_sites
    end

    def update
      @user = ::Cas::User.find(params[:id])
      success = nil
      @user.site_ids = user_params[:site_ids]
      if user_params[:password].blank? && user_params[:password_confirmation].blank?
        without_password = user_params.except(:password, :password_confirmation)
        success = @user.update_without_password(without_password)
      else
        success = @user.update(user_params)
      end

      if success
        redirect_to site_users_url(@site)
      else
        get_selected_sites
        render 'edit'
      end
    end

    private

    def user_params
      site_ids = Array.wrap(params[:user][:site_ids]) << @site.id
      params
        .require(:user)
        .permit(
          :name,
          :email,
          :site_ids,
          :password,
          :password_confirmation,
          :roles,
        )
        .merge!(
          roles: [params[:user][:roles]],
          site_ids: (site_ids).uniq.keep_if(&:present?)
        )
    end

    def get_selected_sites
      @selected_sites = @user.sites.map(&:id)
      @selected_sites << @site.id if @user.new_record?
    end
  end
end
