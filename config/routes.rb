Rails.application.routes.draw do
  root 'users#index'

  resources :hashtags, :only => [:show, :create]
  resources :search, :only => [:index]
  #get 'hashtag/:id', to: 'hashtag#show'

  resources :users, :only => [:index, :show, :edit, :update]
end
