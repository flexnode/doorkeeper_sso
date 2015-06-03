module Sso
  module Doorkeeper
    module ApplicationMixin
      extend ActiveSupport::Concern
      include ::Sso::Logging

      included do
        has_many :sso_clients, class_name: 'Sso::Client', foreign_key: :application_id
      end
    end
  end
end
