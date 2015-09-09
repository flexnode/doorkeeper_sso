# Doorkeeper::OAuth::Authorization::Token extensions
# This module extends oauth authorization classes to publish a wisper event when token is issued

module Sso
  module Doorkeeper
    module Authorization
      module TokenMixin
        def issue_token
          # debug { "CodeMixin#access_token_created" }
          super
          broadcast(:access_token_created, token.id) if @token.try(:id)
          @token
        end
      end
    end
  end
end
