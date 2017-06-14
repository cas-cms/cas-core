Rails.application.routes.draw do
  mount Cas::Engine => "/admin"
end
