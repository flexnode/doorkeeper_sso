module Sso
  module Doorkeeper
    module AuthorizationsControllerMixin
      extend ActiveSupport::Concern
      include ::Sso::Logging

      included do
        after_action :after_grant_create, only: [:new, :create]
      end

    protected

      def after_grant_create
        debug { "AuthorizationsController#Create : after_action" }
        code_response = authorization.instance_variable_get("@response")
        oauth_grant = code_response.try(:auth).try(:token)

        warden_session = session["warden.user.user.session"]
        session = Sso::Session.find_by!(id: warden_session["sso_session_id"])

        if session.try(:active?)
          error { "AuthorizationsControllerMixin - Sso::Session Inactive #{session.inspect}"}
          warden.logout(:user) and return
        end

        if oauth_grant
          debug { "Sso::Session.update_master_with_grant - #{session.id.inspect}, #{oauth_grant.inspect}" }
          session.clients.find_or_create_by!(access_grant_id: oauth_grant.id)
        else
          error { "AuthorizationsControllerMixin - Unable to get grant id"}
          warden.logout(:user) and return
        end
      end
    end
  end
end