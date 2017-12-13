require_dependency "cas/application_controller"

module Cas
  class Sites::UsersController < ApplicationController
    def index
      @users = ::Cas::User.order('name ASC')
    end

    def new
      @user = ::Cas::User.new
    end

    def create
      @user = ::Cas::User.new(user_params)
      @user.roles = user_params[:roles]
      if @user.save
        redirect_to users_path
      else
        render :new
      end
    end

    def edit
      @user = ::Cas::User.find(params[:id])
    end

    def update
      @user = ::Cas::User.find(params[:id])
      success = nil
      if user_params[:password].blank? && user_params[:password_confirmation].blank?
        without_password = user_params.except(:password, :password_confirmation)
        success = @user.update_without_password(without_password)
      else
        success = @user.update_attributes(user_params)
      end

      if success
        redirect_to users_path
      else
        render 'edit'
      end
    end

    private

    def user_params
      params
        .require(:user)
        .permit(
          :name,
          :email,
          :password,
          :password_confirmation,
          :roles
        )
        .merge!(
          roles: [params[:user][:roles]]
        )
    end
  end
end
