Rails.application.routes.draw do
  root 'users#index'

  resources :hashtags, :only => [:show, :create, :update]
  resources :search, :only => [:index]
  #get 'hashtag/:id', to: 'hashtag#show'

  resources :users, :only => [:index, :show, :edit, :update]

  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'

  post 'join', to: 'hashtags#join'
  delete 'leave', to: 'hashtags#leave'

end
