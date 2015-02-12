Rails.application.routes.draw do
  root 'frontpage#index'

  get 'login', to: 'user#index'

  resources :hashtags, only: [:show, :create, :update]
  resources :users, only: [:index, :show, :edit, :update]
  resources :feed, only: [:index]
  resources :search, only: [:index]

  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'

  post 'join', to: 'hashtags#join'
  delete 'leave', to: 'hashtags#leave'
end
