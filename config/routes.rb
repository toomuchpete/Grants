Rails.application.routes.draw do
  post 'cart_items/checkout'
  post 'cart_items/empty'

  get "logout" => "sessions#destroy", as: "logout"
  get "login" => "sessions#new", as: "login"
  get "signup" => "users#new", as: "signup"
  resources :users
  resources :sessions
  resources :donations
  resources :products
  resources :purchases
  resources :cart_items, only: [:index, :destroy, :create]

  root 'homepage#index'

end
