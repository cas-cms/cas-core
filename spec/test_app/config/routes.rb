Rails.application.routes.draw do
  mount Cas::Engine, at: "/admin"
end
