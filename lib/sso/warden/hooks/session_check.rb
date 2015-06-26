module Sso
  module Warden
    module Hooks
      class SessionCheck
        include ::Sso::Warden::Support

        def call
          debug { "Starting hook after user is fetched into the session" }

          unless logged_in? && Sso::Session.find_by_id(session["sso_session_id"]).try(:active?)
            warden.logout(scope)
            throw(:warden, :scope => scope, :reason => "Sso::Session INACTIVE")
          end
        end
      end
    end
  end
end
