Sso::Engine.routes.draw do
  resource :sessions, :only => [:show, :create]
end
