module Sso
  class SessionsController < Sso::ApplicationController

    before_action :authenticate_user!, only: :jsonp
    before_action :doorkeeper_authorize!, only: [:show, :create]

    # TODO: Security issue?
    protect_from_forgery with: :null_session

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
      respond_with @session, :location => sso.sessions_url
    end

    # Passport exchange
    # Passport Strategy first exchange
    # Insider : Client information from Apps should always be trusted
    def create
      # passport.load_user!
      # passport.create_chip!
      current_client = ::Sso::Client.find_by_access_token(doorkeeper_token.token)
      current_client.update!(client_params)

      @session = current_client.session
      respond_with @session, :location => sso.sessions_url
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
      render :nothing => true
      # respond_with @session, :location => sso.sessions_url
    end



  protected

    def current_client
      @client = doorkeeper_token.sso_client
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
