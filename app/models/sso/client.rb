module Sso
  class Client < ActiveRecord::Base
    include ::Sso::Logging

    belongs_to :session, class_name: 'Sso::Session', foreign_key: :sso_session_id
    belongs_to :application, class_name: 'Doorkeeper::Application',  inverse_of: :sso_clients
    belongs_to :access_grant, class_name: 'Doorkeeper::AccessGrant', inverse_of: :sso_client
    belongs_to :access_token, class_name: 'Doorkeeper::AccessToken', inverse_of: :sso_client

    validates :access_grant_id, uniqueness: { allow_nil: true }
    validates :access_token_id, uniqueness: { allow_nil: true }

    scope :with_access_token, -> { where.not(access_token: nil) }

    class << self
      def find_by_grant_token(token)
        find_by(access_grant: ::Doorkeeper::AccessGrant.by_token(token))
      end

      def find_by_access_token(token)
        find_by(access_token: ::Doorkeeper::AccessToken.by_token(token))
      end

      def create_from_access_token(session, token_id)
        return false unless oauth_token = ::Doorkeeper::AccessToken.find_by(id: token_id)
        client = session.find_or_create_by(access_token_id: token_id)
      end
    end

    def update_access_token(token)
      return false unless oauth_token = ::Doorkeeper::AccessToken.by_token(token)
      update(access_token_id: oauth_token.id, application_id: oauth_token.application.id)
    end
  end
end
