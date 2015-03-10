Rails.application.routes.draw do
  root 'frontpage#index'

  get 'login', to: 'user#index'

  resources :hashtags, only: [:show, :create, :update]
  resources :users
  resources :feed, only: [:index]
  resources :search, only: [:index]
  resources :invite, only: [:index, :send_email]
  resources :user_hashtags, only: [:update]

  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'

<<<<<<< HEAD
  get 'auth/shibboleth/callback', to: 'session#callback'

=======
>>>>>>> dev
  post 'join', to: 'hashtags#join'
  delete 'leave', to: 'hashtags#leave'

  match '/invite', to: 'invite#send_email', via: 'post'
end
