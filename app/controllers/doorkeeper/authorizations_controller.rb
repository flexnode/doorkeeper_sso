module Doorkeeper
  class AuthorizationsController < Doorkeeper::ApplicationController

    after_action :after_grant_create, only: [:new, :create]

  protected

    def after_grant_create
      Rails.logger.info "AuthorizationsController#Create : after_action"
      code_response = authorization.instance_variable_get("@response")
      if code_response
        warden_session = session["warden.user.user.session"]
        Rails.logger.debug "Sso::Session.update_master_with_grant - #{warden_session["sso_session_id"].inspect}, #{code_response.auth.token.inspect}"
        Sso::Session.update_master_with_grant(warden_session["sso_session_id"], code_response.auth.token)
      end
    end
  end
end