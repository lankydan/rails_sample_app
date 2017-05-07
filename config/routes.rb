Rails.application.routes.draw do

  # This changes the path to the page
  # Original was:             get 'static_pages/contact'  
  # which mapped to the path: static_pages_contact
  get 'contact', to: 'static_pages#contact'

  get 'home', to: 'static_pages#home'

  get 'help', to: 'static_pages#help'

  get 'about', to: 'static_pages#about'

  get 'signup', to: 'users#new'

  # added due to incorrect controller name so I needed to match it to the GET signup_path
  post 'signup', to: 'users#create'

  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"

  resources :users
  # using as: allows me to override the helper paths used
  # this allows the correction to my controller having the wrong name
  # so rails can use its normal paths without me needing to specify one each time
  # resources :users, controller: "user" # need to double check this when refreshing pages

   
  # ActiveSupport::Inflector.inflections do |inflect|
  #   inflect.irregular 'user', 'users'
  # end

  root 'static_pages#home'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
