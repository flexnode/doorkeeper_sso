module Sso
  # class ApplicationController < RocketPants::Base
  #   extend Apipie::DSL::Controller
  class ApplicationController < ::ApplicationController
    # include ::Doorkeeper::Helpers::Controller

    # TODO: Security issue?
    protect_from_forgery
    # Bug in devise so we skip protect_from_forgery for only create
    # http://stackoverflow.com/questions/20875591/actioncontrollerinvalidauthenticitytoken-in-registrationscontrollercreate
    # http://stackoverflow.com/questions/23773730/rails-4-skipping-protect-from-forgery-for-api-actions
    # skip_before_action :verify_authenticity_token, if: :json_request?

 protected

    def json_request?
      request.format.json?
    end

  end
end
