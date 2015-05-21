module Sso
  module Doorkeeper
    module AccessGrantMixin
      extend ActiveSupport::Concern
      include ::Sso::Logging

      included do
        has_many :sso_clients, class_name: 'Sso::Client', foreign_key: :access_grant_id
      end
    end
  end
end
