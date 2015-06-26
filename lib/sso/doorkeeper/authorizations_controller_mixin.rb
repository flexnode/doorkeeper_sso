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

        warden_session = session["warden.user.user.session"] || {}
        sso_session = Sso::Session.find_by_id(warden_session["sso_session_id"].to_s)

        unless sso_session.try(:active?)
          error { "ERROR : AuthorizationsControllerMixin  - Sso::Session INACTIVE) #{sso_session.inspect}" }
          return false
        end

        if oauth_grant
          debug { "Sso::Session.update_master_with_grant - #{sso_session.id.inspect}, #{oauth_grant.inspect}" }
          sso_session.clients.find_or_create_by!(access_grant_id: oauth_grant.id)
        else
          error { "ERROR : AuthorizationsControllerMixin - Unable to get grant id from #{oauth_grant.inspect}" }
          sso_session.logout
          return false
        end
      end
    end
  end
end