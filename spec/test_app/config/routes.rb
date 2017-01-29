Rails.application.routes.draw do
  mount Cas::Engine => "/cas"
end
