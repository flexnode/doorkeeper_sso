module Sso
  class Engine < ::Rails::Engine
    isolate_namespace Sso

    # New test framework integration
    config.generators do |g|
      g.test_framework  :rspec,
                        :fixtures => true,
                        :view_specs => false,
                        :helper_specs => false,
                        :routing_specs => false,
                        :controller_specs => true,
                        :request_specs => false
      g.fixture_replacement :fabrication
    end

    initializer :append_migrations do |app|
      unless app.root.to_s.match root.to_s
        config.paths["db/migrate"].expanded.each do |expanded_path|
          app.config.paths["db/migrate"] << expanded_path
        end
      end
    end

    config.after_initialize do
      ::Doorkeeper::Application.send(:include, Sso::Doorkeeper::ApplicationMixin)
      ::Doorkeeper::AccessGrant.send(:include, Sso::Doorkeeper::AccessGrantMixin)
      ::Doorkeeper::AccessToken.send(:include, Sso::Doorkeeper::AccessTokenMixin)


      ::Doorkeeper::TokensController.send(:include, AbstractController::Callbacks)
      ::Doorkeeper::TokensController.send(:include, Sso::Doorkeeper::TokensControllerMixin)
      ::Doorkeeper::AuthorizationsController.send(:include, Sso::Doorkeeper::AuthorizationsControllerMixin)

      ::Warden::Manager.after_authentication(scope: :user, &::Sso::Warden::Hooks::AfterAuthentication.to_proc)
      ::Warden::Manager.before_logout(scope: :user, &::Sso::Warden::Hooks::BeforeLogout.to_proc)

      # TODO : Do we want to ensure that session is always active?
      # ::Warden::Manager.after_fetch(scope: :user, &::Sso::Warden::Hooks::SessionCheck.to_proc)

      # TODO : Why does it need a passport strategy
      # Warden::Strategies.add :passport, ::Sso::Server::Warden::Strategies::Passport
    end
  end
end
