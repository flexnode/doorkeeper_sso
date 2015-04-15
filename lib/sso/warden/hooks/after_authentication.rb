module Sso
  module Warden
    module Hooks
      class AfterAuthentication
        include ::Sso::Logging

        attr_reader :user, :warden, :options

        def self.to_proc
          proc do |user, warden, options|
            new(user: user, warden: warden, options: options).call
          end
        end

        def initialize(user:, warden:, options:)
          @user, @warden, @options = user, warden, options
        end

        def call
          debug { "Starting hook because this is considered the first login of the current session..." }
          request = warden.request
          session = warden.session(:user)

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
