module Sso
  class SessionsController < ApplicationController

    before_action :authenticate_user!, only: :show
    before_action :doorkeeper_authorize!, only: :create
    before_action :find_user, only: :create

    # TODO: Security issue?
    protect_from_forgery with: :null_session

    respond_to :json

    # Returns a 200 if access is granted
    def show
      render :nothing => true
    end

    # Generate an SSO:Session
    def create
      #render json: {}
      client = ::Sso::Client.find_by_access_token(doorkeeper_token.token)
      client.update!(client_params)
      @session = client.session
      respond_with @session, :location => sso.sessions_url
    end

    protected

    def find_user
      @user = User.find(doorkeeper_token.resource_owner_id)
    end

    def client_params
      params.permit(:ip, :agent)
    end

  end
end
