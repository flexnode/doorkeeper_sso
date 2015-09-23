module Sso
  module Doorkeeper
    module ApplicationControllerMixin
      extend ActiveSupport::Concern
      include ::Sso::Logging

      included do
        around_filter :subscribe_to_grant_creation
      end

      def subscribe_to_grant_creation
        Wisper.subscribe(self) do
          yield
        end
      end

      def warden
        env["warden"]
      end

      def warden_user_session
        warden.session(:user)
      end

      def access_grant_created(token_id)
        debug { "Wisper#access_grant_created grant - #{token_id}" }
        oauth_grant = ::Doorkeeper::AccessGrant.find(token_id)

        generate_sso_session if warden_user_session["sso_session_id"].blank?
        sso_session = Sso::Session.find(warden_user_session["sso_session_id"])

        debug { "Sso::Session.update_master_with_grant - #{sso_session.id.inspect}, #{oauth_grant.inspect}" }
        sso_session.clients.find_or_create_by!(access_grant_id: oauth_grant.id, application_id: oauth_grant.application_id)
      rescue => e
        sso_session.try(:logout)
        raise
      end

      def generate_sso_session
        debug { "Sso:Session doesn't exist for user #{user.id.inspect}. Generate new one" }
        attributes = {  ip: request.ip, agent: request.user_agent }
        sso_session = Sso::Session.generate_master(user, attributes)
        warden_user_session["sso_session_id"] = sso_session.id.to_s
      end
    end
  end
end
