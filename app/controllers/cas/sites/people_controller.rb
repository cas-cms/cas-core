require_dependency "cas/application_controller"

module Cas
  class Sites::PeopleController < Sites::ApplicationController
    def index
      @people = @site.people.order('name ASC')
    end

    def new
      @person = ::Cas::Person.new
      get_selected_sites
    end

    def create
      @person = ::Cas::Person.new(person_params)
      @person.roles = person_params[:roles]
      @person.site_ids = person_params[:site_ids]
      if @person.save
        redirect_to site_people_url(@site)
      else
        get_selected_sites
        render :new
      end
    end

    def edit
      @person = ::Cas::Person.find(params[:id])
      get_selected_sites
    end

    def update
      @person = ::Cas::Person.find(params[:id])
      success = nil
      @person.site_ids = person_params[:site_ids]
      if person_params[:password].blank? && person_params[:password_confirmation].blank?
        without_password = person_params.except(:password, :password_confirmation)
        success = @person.update_without_password(without_password)
      else
        success = @person.update_attributes(person_params)
      end

      if success
        redirect_to site_people_url(@site)
      else
        get_selected_sites
        render 'edit'
      end
    end

    private

    def person_params
      site_ids = Array.wrap(params[:person][:site_ids]) << @site.id
      params
        .require(:person)
        .permit(
          :name,
          :email,
          :site_ids,
          :password,
          :password_confirmation,
          :roles,
        )
        .merge!(
          roles: [params[:person][:roles]],
          site_ids: (site_ids).uniq.keep_if(&:present?)
        )
    end

    def get_selected_sites
      @selected_sites = @person.sites.map(&:id)
      @selected_sites << @site.id if @person.new_record?
    end
  end
end
