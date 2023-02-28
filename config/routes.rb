require 'sidekiq/web'
# TODO - need to migrate Sidekiq
#Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Cas::Engine.routes.draw do
  if Shrine.respond_to?(:presign_endpoint)
    mount Shrine.presign_endpoint(:cache) => "/files/cache/presign"
  else
    Rails.logger.info "Shrine's presign endpoint is disabled"
  end

  # TODO - fix
  # mount Shrine.upload_endpoint(:cache) => "/files/upload"

  authenticate :user, ->(u){ u.roles.include?('admin') } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users,
    class_name: "Cas::User",
    module: :devise,
    controllers: { sessions: "cas/devise/sessions" },
    skip: :registrations

  resources :activities, only: [:index]
  resources :sites, only: [:index] do
    resources :users, controller: 'sites/users'

    resources :sections, only: [:index], controller: 'sites/sections' do
      resources :contents, controller: 'sites/sections/contents'
      resources :categories, controller: 'sites/sections/categories'
    end
  end

  # used by tinymce editor
  resources :file_uploads, only: :create
  namespace :api, module: "api" do
    resources :files, only: [:create, :destroy]
  end

  root 'sites/sections#index'
end
