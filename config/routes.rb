Cas::Engine.routes.draw do
  mount FileUploader::UploadEndpoint => "/files"

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
  root 'sections#index'
end
