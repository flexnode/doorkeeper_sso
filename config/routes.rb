Sso::Engine.routes.draw do
  resource :sessions, :only => [:show, :create] do
     get 'id', on: :collection
  end
end
