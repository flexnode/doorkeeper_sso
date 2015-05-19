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

    config.after_initialize do

      ::Doorkeeper::TokensController.send(:include, AbstractController::Callbacks)
      ::Doorkeeper::TokensController.send(:include, Sso::Doorkeeper::TokensControllerMixin)
      ::Doorkeeper::AuthorizationsController.send(:include, Sso::Doorkeeper::AuthorizationsControllerMixin)

      ::Warden::Manager.after_authentication(scope: :user, &::Sso::Warden::Hooks::AfterAuthentication.to_proc)
      ::Warden::Manager.before_logout(scope: :user, &::Sso::Warden::Hooks::BeforeLogout.to_proc)

      # TODO : Why does it need a passport strategy
      # Warden::Strategies.add :passport, ::Sso::Server::Warden::Strategies::Passport

    end
  end
end
