Sso::Engine.routes.draw do
  resource :sessions, :only => [:show, :create] do
    collection do
      get :jsonp
    end
  end
end
