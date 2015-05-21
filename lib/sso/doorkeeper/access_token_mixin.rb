module Sso
  module Doorkeeper
    module AccessTokenMixin
      extend ActiveSupport::Concern
      include ::Sso::Logging

      included do
        has_many :sso_clients, class_name: 'Sso::Client', foreign_key: :access_token_id
      end
    end
  end
end
