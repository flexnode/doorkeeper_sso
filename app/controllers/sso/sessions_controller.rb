module Sso
  class SessionsController < Sso::ApplicationController
    include ::Sso::Logging

    before_action :authenticate_user!, only: [:jsonp]
    before_action :doorkeeper_authorize!, only: [:show, :create]
    respond_to :json

    ################################################################################
    # OAuth2 Endpoint
    ################################################################################

    # Passport verification
    # Session exists (browser/insider) - return passport state
    # Sessionless (iphone/outsider)
    # Returns passport
    def show
      @session = current_client.session
      render json: @session, serializer: Sso::SessionSerializer
    end

    # Passport exchange
    # Passport Strategy first exchange
    # Insider : Client information from Apps should always be trusted
    def create
      @session = current_client.session
      debug { "SessionsController#create - #{@session.inspect}"}
      raise "ResourceOwner from token != session.owner" if doorkeeper_token.resource_owner_id != @session.owner.id

      current_client.update_attributes!(client_params)
      render json: @session, status: :created, serializer: Sso::SessionSerializer
    end

    ################################################################################
    # JSONP endpoint based on Devise session
    ################################################################################
    def jsonp
      # TODO : Check inconsistent
      render :nothing => true
      # respond_with @session, :location => sso.sessions_url
    end


    ################################################################################
    # Mobile endpoint
    ################################################################################
    def mobile
      # TODO : Check inconsistent

      # passport.load_user!
      # passport.create_chip!
      render :nothing => true
      # respond_with @session, :location => sso.sessions_url
    end



  protected

    def current_client
      @current_client ||= doorkeeper_token.sso_client
    end

    def current_resource_owner
      @current_resource_owner ||= User.find(doorkeeper_token.resource_owner_id)
    end

    def current_session
      @current_session = current_client.session
    end

    def client_params
      params.permit(:ip, :agent)
    end

  end
end


#passport exchange
          # finding = ::SSO::Server::Passports.find_by_access_token_id(access_token.id)
          # if finding.failure?
          #   # This should never happen. Every Access Token should be connected to a Passport.
          #   return json_error :passport_not_found
          # end
          # passport = finding.object

          # ::SSO::Server::Passports.update_activity passport_id: passport.id, request: request

          # debug { "Attaching user and chip to passport #{passport.inspect}" }
          # passport.load_user!
          # passport.create_chip!

          # payload = { success: true, code: :here_is_your_passport, passport: passport.export }
          # debug { "Created Passport #{passport.id}, sending it including user #{passport.user.inspect}}" }

          # [200, { 'Content-Type' => 'application/json' }, [payload.to_json]]

#passport  verification

          # if request.get? && request.path == passports_path
          #   debug { 'Detected incoming Passport verification request.' }
          #   env['warden'].authenticate! :passport
