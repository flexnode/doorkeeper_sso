module Sso
  class TokenMarker
    include Sso::Logging
    attr_accessor :session_id

    def initialize(sid)
      debug { "Sso::TokenMarker#new session_id - #{sid}" }
      @session_id = sid
      return self
    end

    def access_grant_created(token_id)
      debug { "Wisper#access_grant_created grant - #{token_id}" }
      grant = ::Doorkeeper::AccessGrant.find(token_id)
    end

    def access_token_created(token_id)
      debug { "Wisper#access_token_created token - #{token_id}" }
      token = ::Doorkeeper::AccessToken.find(token_id)
    end

    def access_token_request_successful(token_id)
      debug { "Wisper#access_token_request_successful token - #{token_id}" }
      token = ::Doorkeeper::AccessToken.find(token_id)
    end

    def create_session
      Sso::Session.generate_master()
    end
  end
end
