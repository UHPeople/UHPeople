Rails.application.routes.draw do
  root 'frontpage#index'

  %w( 404 422 500 ).each do |code|
    get "/#{code}", to: 'errors#error', code: code
  end

  resources :hashtags, only: [:index, :show, :create, :update], param: :tag
  post 'hashtags/:tag/invite', to: 'hashtags#invite'
  post 'join', to: 'hashtags#join'
  delete 'leave', to: 'hashtags#leave'
  delete 'leave_and_destroy', to: 'hashtags#leave_and_destroy'

  resources :users, only: [:index, :show, :new, :create, :edit, :update]
  resources :feed, only: [:index]
  resources :search, only: [:index]
  resources :invite, only: [:index, :send_email]
  resources :user_hashtags, only: [:update]
  resources :notifications, only: [:index]
  resources :photos, only: [:show, :create, :destroy, :update]
  resources :about, only: [:index]


  get 'login', to: 'user#index'
  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'
  get 'threehash', to: 'hashtags#three_hash'
  put 'add_multiple', to: 'hashtags#add_multiple'
  get 'auth/shibboleth/callback', to: 'users#shibboleth_callback'

  match '/invite', to: 'invite#send_email', via: 'post'

  post 'notifications/seen', to: 'notifications#seen', via: 'post'

  post 'set_profile_picture', to: 'users#set_profile_picture'
  post 'firsttime/:value', to: 'users#set_first_time_use', as: 'first_time'
  post 'tab/:value', to: 'users#set_tab', as: 'tab'

  post 'set_first_time_use', to: 'users#set_first_time_use'
  post 'update_last_visit/:id', to: 'user_hashtags#update_last_visit', via: 'post'

  post 'like_this/:id', to: 'like#index', via: 'post'
  get 'get_message_likers/:id', to: 'message#get_message_likers'
  get 'privacy_policy', to: 'about#privacy_policy'
  get 'users/:id/photos', to: 'users#photos', as: 'user_photos'
end
