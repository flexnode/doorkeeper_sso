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
      if code_response
        warden_session = session["warden.user.user.session"]
        debug { "Sso::Session.update_master_with_grant - #{warden_session["sso_session_id"].inspect}, #{code_response.auth.token.inspect}" }
        Sso::Session.update_master_with_grant(warden_session["sso_session_id"], code_response.auth.token)
      end
    end
  end
end
