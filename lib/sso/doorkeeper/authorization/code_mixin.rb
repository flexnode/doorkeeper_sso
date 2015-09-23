# Doorkeeper::OAuth::Authorization::Code extensions
# This module extends oauth authorization classes to publish a wisper event when token is issued

module Sso
  module Doorkeeper
    module Authorization
      module CodeMixin
        def issue_token
          super
          broadcast(:access_grant_created, token.id) if @token.try(:id)
          @token
        end
      end
    end
  end
end
