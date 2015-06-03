require 'active_support/concern'

module Sso
  module Doorkeeper
    module TokensControllerMixin
      extend ActiveSupport::Concern
      include ::Sso::Logging

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

        unless client = ::Sso::Client.find_by_grant_token(grant_token)
          error { "::Sso::Client not found for grant token #{grant_token}" }
        end

        if client.update_access_token(outgoing_access_token)
          debug { "::Sso::Client.update_access_token success for access_token: #{outgoing_access_token}" }
        else
          error { "::Sso::Session.update_access_token failed. #{client.errors.inspect}" }
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
