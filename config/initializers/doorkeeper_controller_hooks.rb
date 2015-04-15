Doorkeeper::TokensController.class_eval do
  include AbstractController::Callbacks

  after_action :after_token_create, only: :create

protected

  def after_token_create
    Rails.logger.info "TokensController#Create : after_action"
    handle_authorization_grant_flow
  end

  def handle_authorization_grant_flow
    # We cannot rely on session[:sso_session_id] here because the end-user might have cookies disabled.
    # The only thing we can rely on to identify the user/Passport is the incoming grant token.
    Rails.logger.debug { %(Detected outgoing "Access Token" #{outgoing_access_token.inspect}) }
    if sso_session = Sso::Session.update_master_with_access_token(grant_token, outgoing_access_token)
      Rails.logger.debug "::Sso::Session.register_access_token success for access_token: #{outgoing_access_token}"
    else
      Rails.logger.debug "::Sso::Session.register_access_token failed. #{sso_session.errors.inspect}"
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


Doorkeeper::AuthorizationsController.class_eval do

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