Cas::Engine.routes.draw do
  resources :sections, only: [:index] do
    resources :contents, controller: 'sections/contents'
  end
  root 'sections#index'
end
