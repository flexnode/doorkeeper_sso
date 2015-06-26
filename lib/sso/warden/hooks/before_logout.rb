module Sso
  module Warden
    module Hooks
      class BeforeLogout
        include ::Sso::Warden::Support

        def call
          # Only run if user is logged in
          if logged_in?
            debug { "#BeforeLogout Sso::Session - #{session["sso_session_id"]}" }
            debug { "user is #{user.inspect}" }
            ::Sso::Session.logout(session["sso_session_id"])
          end
          return nil
        end
      end
    end
  end
end
