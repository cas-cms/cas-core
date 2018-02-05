Rails.application.routes.draw do
  mount Cas::Engine => "/"
  mount JasmineRails::Engine => '/specs'
end
