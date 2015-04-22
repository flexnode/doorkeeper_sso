require 'active_support/concern'

module Sso
  module Doorkeeper
    module TokensControllerMixin
      extend ActiveSupport::Concern

      included do
        after_action :after_token_create, only: :create
      end

      protected

      def after_token_create
        debug { "TokensController#Create : after_action" }
        handle_authorization_grant_flow
      end

      def handle_authorization_grant_flow
        # We cannot rely on session[:sso_session_id] here because the end-user might have cookies disabled.
        # The only thing we can rely on to identify the user/Passport is the incoming grant token.
        debug { %(Detected outgoing "Access Token" #{outgoing_access_token.inspect}) }
        if sso_session = Sso::Session.update_master_with_access_token(grant_token, outgoing_access_token)
          debug { "::Sso::Session.register_access_token success for access_token: #{outgoing_access_token}" }
        else
          debug { "::Sso::Session.register_access_token failed. #{sso_session.errors.inspect}" }
          warden.logout
        end
      end

      def grant_token
        params["code"]
      end

      def grant_type
        params["grant_type"]
      end

      def outgoing_access_token
        @response_hash ||= JSON.parse(response.body)
        @response_hash["access_token"]
      end
    end
  end
end
