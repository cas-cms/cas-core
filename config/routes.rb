require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Cas::Engine.routes.draw do
  mount Shrine.presign_endpoint(:cache) => "/files/cache/presign"

  authenticate :person, ->(u){ u.roles.include?('admin') } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :people,
    class_name: "Cas::Person",
    module: :devise,
    controllers: { sessions: "cas/devise/sessions" },
    skip: :registrations

  resources :activities, only: [:index]
  resources :sites, only: [:index] do
    resources :people, controller: 'sites/people'

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
