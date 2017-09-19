require 'sidekiq/web'
Sidekiq::Web.set :session_secret, Rails.application.secrets[:secret_key_base]

Cas::Engine.routes.draw do
  mount Shrine.presign_endpoint(:cache) => "/files/cache/presign"

  authenticate :user, ->(u){ u.roles.include?('admin') } do
    mount Sidekiq::Web => '/sidekiq'
  end

  devise_for :users,
    class_name: "Cas::User",
    module: :devise,
    controllers: { sessions: "cas/devise/sessions" },
    skip: :registrations

  resources :users, controller: 'users'

  resources :sections, only: [:index] do
    resources :contents, controller: 'sections/contents'
    resources :categories, controller: 'sections/categories'
  end

  # used by tinymce editor
  resources :file_uploads, only: :create
  namespace :api, module: "api" do
    resources :files, only: [:create, :destroy]
  end

  root 'sections#index'
end
