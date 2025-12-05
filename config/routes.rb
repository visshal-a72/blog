require 'sidekiq/web'

Rails.application.routes.draw do
  # Mount Sidekiq Web UI (protect in production!)
  mount Sidekiq::Web => '/sidekiq'

  root "articles#index"

  resources :articles do
    resources :comments
  end
end
