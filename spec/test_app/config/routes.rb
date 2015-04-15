Rails.application.routes.draw do
  use_doorkeeper

  # Devise
  devise_for :users

  mount Sso::Engine => '/sso'
end
