Rails.application.routes.draw do

  mount Sso::Engine => "/sso"
end
