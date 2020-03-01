Rails.application.routes.draw do
  resources :identifiers
  root "identifiers#index"
end
