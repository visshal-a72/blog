require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'

  # Authentication routes
  get    'login',  to: 'user_sessions#new',     as: :login
  post   'login',  to: 'user_sessions#create'
  delete 'logout', to: 'user_sessions#destroy', as: :logout
  
  # Registration routes
  get  'register', to: 'users#new',    as: :register
  post 'register', to: 'users#create'
  
  # Profile routes
  get   'profile', to: 'users#edit',   as: :profile
  patch 'profile', to: 'users#update'

  root "articles#index"

  resources :articles do
    resources :comments
  end
end
