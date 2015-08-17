module Sso
  module Warden
    module Hooks
      class CreateMasterSession
        include ::Sso::Warden::Support

        def call
          if logged_in?
            debug { "Starting hook because this is considered the first login of the current session..." }
            debug { "Log out previous Sso:Session if exists : ID session['sso_session_id']" }
            ::Sso::Session.logout(session["sso_session_id"])
            generate_session
          end
          return nil
        end

        def generate_session
          debug { "Generating a Sso:Session for user #{user.id.inspect} for the session cookie at the Sso server..." }
          attributes = {  ip: request.ip, agent: request.user_agent }

          sso_session = Sso::Session.generate_master(user, attributes)
          debug { "Sso:Session with ID #{sso_session.id} generated successfuly. Persisting it in session..." }
          session["sso_session_id"] = sso_session.id.to_s
        end
      end
    end
  end
end
