module Sso
  class Client < ActiveRecord::Base
    include ::Sso::Logging

    belongs_to :session, class_name: 'Sso::Session', foreign_key: :sso_session_id
    belongs_to :application, class_name: 'Doorkeeper::Application',  inverse_of: :sso_clients
    belongs_to :access_grant, class_name: 'Doorkeeper::AccessGrant', inverse_of: :sso_client
    belongs_to :access_token, class_name: 'Doorkeeper::AccessToken', inverse_of: :sso_client

    validates :access_grant_id, uniqueness: { allow_nil: true }
    validates :access_token_id, uniqueness: { allow_nil: true }

    class << self
      def find_by_grant_token(token)
        find_by!(access_grant: ::Doorkeeper::AccessGrant.by_token(token))
      end

      def find_by_access_token(token)
        find_by!(access_token: ::Doorkeeper::AccessToken.by_token(token))
      end
    end

    def update_access_token(token)
      oauth_token = ::Doorkeeper::AccessToken.by_token(token)
      update(access_token_id: oauth_token.id, application_id: oauth_token.application.id)
    end
  end
end
