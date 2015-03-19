Rails.application.routes.draw do
  root 'frontpage#index'

  get 'login', to: 'user#index'

  resources :hashtags, only: [:show, :create, :update]
  resources :users
  resources :feed, only: [:index]
  resources :search, only: [:index]
  resources :invite, only: [:index, :send_email]
  resources :user_hashtags, only: [:update]
  resources :notifications, only: [:index]

  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'

  get 'auth/shibboleth/callback', to: 'session#callback'

  post 'join', to: 'hashtags#join'
  delete 'leave', to: 'hashtags#leave'

  match '/invite', to: 'invite#send_email', via: 'post'
  post 'notifications/:id', to: 'notifications#update', via: 'post' 

end
