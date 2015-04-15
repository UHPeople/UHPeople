Rails.application.routes.draw do
  root 'frontpage#index'

  %w( 404 422 500 ).each do |code|
    get "/#{code}", to: 'errors#error', code: code
  end

  get 'login', to: 'user#index'

  resources :hashtags, only: [:index, :show, :create, :update]
  resources :users, only: [:index, :show, :new, :create, :edit, :update]
  resources :feed, only: [:index]
  resources :search, only: [:index]
  resources :invite, only: [:index, :send_email]
  resources :user_hashtags, only: [:update]
  resources :notifications, only: [:index]
  resources :photos, only: [:show, :create, :destroy, :update]

  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'

  get 'threehash', to: 'hashtags#three_hash'
  patch 'add', to: 'hashtags#add'

  get 'auth/shibboleth/callback', to: 'users#shibboleth_callback'

  post 'hashtags/:id/invite', to: 'hashtags#invite'

  post 'join', to: 'hashtags#join'
  delete 'leave', to: 'hashtags#leave'

  match '/invite', to: 'invite#send_email', via: 'post'
  
  post 'notifications/:id', to: 'notifications#update', via: 'post'

  post 'set_profile_picture', to: 'users#set_profile_picture'

  post 'firsttime/:value', to: 'users#set_first_time_use', as: 'first_time'

end
