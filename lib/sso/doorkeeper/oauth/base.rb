module Sso
  module Doorkeeper
    module OAuth
      module Base
        extend ActiveSupport::Concern

        included do
          attr_accessor :sso_client
        end

        def sso_client
          return @sso_client if @sso_client

          user = User.find(@access_token.resource_owner_id)
          sso_session = Sso::Session.generate_master(@access_token.resource_owner_id, attributes)
          @sso_client = sso_session.clients.last
        end

        def after_successful_response
          sso_client.update_attributes(access_token_id: @access_token.id)
          super
        end
      end
    end
  end
end
