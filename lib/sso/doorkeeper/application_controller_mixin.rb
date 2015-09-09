module Sso
  module Doorkeeper
    module ApplicationControllerMixin
      extend ActiveSupport::Concern
      include ::Sso::Logging

      included do
        around_filter :subscribe_to_token_creation
      end

      def subscribe_to_token_creation
        session_id = warden.session(:user).try(:[], "sso_session_id") if warden.authenticated?(:user)
        token_marker = ::Sso::TokenMarker.new(session_id)
        Wisper.subscribe(token_marker) do
          yield
        end
      end

      def warden
        env["warden"]
      end
    end
  end
end
