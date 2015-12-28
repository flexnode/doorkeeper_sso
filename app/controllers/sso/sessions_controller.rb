module Sso
  class SessionsController < Sso::ApplicationController
    include ::Sso::Logging

    before_action :doorkeeper_authorize!, only: :create
    before_action :authenticate_user!, except: :create
    respond_to :json

    ################################################################################
    # OAuth2 Endpoints
    ################################################################################

    # Passport exchange
    # Passport Strategy first exchange
    # Insider : Client information from Apps should always be trusted
    def create
      @client = current_client
      @session = @client.session
      debug { "SessionsController#create - #{@session.inspect}"}
      raise "ResourceOwner from token != session.owner" if doorkeeper_token.resource_owner_id != @session.owner.id

      @client.update_attributes!(client_params)
      render json: @client, status: :created, serializer: Sso::ClientSerializer
    end

    ################################################################################
    # JSONP endpoint based on Devise session
    ################################################################################
    def id
      render json:  { passport_id: sso_session_id }
    end

    # Passport verification
    # Session exists (browser/insider) - return passport state
    # Sessionless (iphone/outsider)
    # Returns passport
    def show
      @session = Sso::Session.find(sso_session_id)
      render json: @session, serializer: Sso::SessionSerializer
    end


  protected

    def sso_session_id
      warden.session(:user)["sso_session_id"]
    end

    def current_client
      @current_client ||= doorkeeper_token.sso_client
    end

    def current_resource_owner
      @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id)
    end

    def client_params
      params.permit(:ip, :agent)
    end

  end
end

