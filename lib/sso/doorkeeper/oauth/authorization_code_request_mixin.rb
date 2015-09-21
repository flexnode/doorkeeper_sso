module Sso
  module Doorkeeper
    module OAuth
      module AuthorizationCodeRequestMixin
        include Base

        def sso_client
          @sso_client ||= grant.sso_client
        end
      end
    end
  end
end
