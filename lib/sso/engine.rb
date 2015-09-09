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

    config.before_initialize do
      [::Sso::Logging, ::Wisper::Publisher].each do |klass|
        ::Doorkeeper::OAuth::RequestConcern.send(:include, klass)
        ::Doorkeeper::OAuth::Authorization::Code.send(:include, klass)
        ::Doorkeeper::OAuth::Authorization::Token.send(:include, klass)
      end

      ::Doorkeeper::ApplicationMetalController.send(:include, ::AbstractController::Callbacks)

      # need a better way to fix this
      ::Doorkeeper::OAuth::RequestConcern.class_eval do
        def after_successful_response
          raise "RequestConcern#token - #{@access_token.inspect}"
          broadcast(:access_token_request_successful, @access_token.id)
          super
        end
      end
    end

    config.after_initialize do

      ::Doorkeeper::OAuth::Authorization::Code.send(:prepend, ::Sso::Doorkeeper::Authorization::CodeMixin)
      ::Doorkeeper::OAuth::Authorization::Token.send(:prepend, ::Sso::Doorkeeper::Authorization::TokenMixin)
      ::Doorkeeper::Application.send(:include,  ::Sso::Doorkeeper::ApplicationMixin)
      ::Doorkeeper::AccessGrant.send(:include,  ::Sso::Doorkeeper::AccessGrantMixin)
      ::Doorkeeper::AccessToken.send(:include,  ::Sso::Doorkeeper::AccessTokenMixin)
      ::Doorkeeper::ApplicationMetalController.send(:include, ::Sso::Doorkeeper::ApplicationControllerMixin)
      ::Doorkeeper::ApplicationController.send(:include, ::Sso::Doorkeeper::ApplicationControllerMixin)
      # ::Doorkeeper::TokensController.send(:include, ::AbstractController::Callbacks)
      # ::Doorkeeper::TokensController.send(:include, ::Sso::Doorkeeper::TokensControllerMixin)
      # ::Doorkeeper::AuthorizationsController.send(:include, ::Sso::Doorkeeper::AuthorizationsControllerMixin)

      ::Warden::Manager.after_set_user(scope: :user, except: :fetch, &::Sso::Warden::Hooks::CreateMasterSession.to_proc)
      ::Warden::Manager.before_logout(scope: :user, &::Sso::Warden::Hooks::BeforeLogout.to_proc)

      # TODO : Do we want to ensure that session is always active?
      # ::Warden::Manager.after_fetch(scope: :user, &::Sso::Warden::Hooks::SessionCheck.to_proc)

      # TODO : Why does it need a passport strategy
      # Warden::Strategies.add :passport, ::Sso::Server::Warden::Strategies::Passport
    end
  end
end
