module Sso
  class Engine < ::Rails::Engine
    isolate_namespace Sso

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    config.after_initialize do

      ::Doorkeeper::TokensController.send(:include, AbstractController::Callbacks)
      ::Doorkeeper::TokensController.send(:include, Sso::Doorkeeper::TokensControllerMixin)
      ::Doorkeeper::AuthorizationsController.send(:include, Sso::Doorkeeper::AuthorizationsControllerMixin)

      ::Warden::Manager.after_authentication(scope: :user, &::Sso::Warden::Hooks::AfterAuthentication.to_proc)
      ::Warden::Manager.before_logout(scope: :user, &::Sso::Warden::Hooks::BeforeLogout.to_proc)
      ::Warden::Manager.after_fetch(scope: :user, &::Sso::Warden::Hooks::AfterAuthentication.to_proc)

      # TODO : Why does it need a passport strategy
      # Warden::Strategies.add :passport, ::Sso::Server::Warden::Strategies::Passport

    end
  end
end
