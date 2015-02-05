Rails.application.routes.draw do
  root 'users#index'

  resources :hashtags, :only => [:show, :create]
  resources :search, :only => [:show]
  #get 'hashtag/:id', to: 'hashtag#show'

  resources :users, :only => [:index, :show, :edit, :update]

  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'
end
