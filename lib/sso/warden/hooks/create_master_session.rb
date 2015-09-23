module Sso
  module Warden
    module Hooks
      class CreateMasterSession
        include ::Sso::Warden::Support

        def call
          unless logged_in?
            throw(:warden)
            raise "DoorkeeperSso : CreateMasterSession requires an authenticated session" and return
          end

          debug { "NEW USER WARDEN SESSION" }
          debug { "Log out previous Sso:Session if exists : ID #{session['sso_session_id']}" }
          ::Sso::Session.logout(session["sso_session_id"])
          generate_session
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
