module Sso
  module Warden
    module Hooks
      class AfterFetch
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
          debug { "Starting hook after user is fetched into the session" }

          # Only run if user is logged in
          if warden.authenticated?(:user) && (session = warden.session(:user))
            debug { "Checking if Sso::Session exist and is still active else logout user" }
            unless Sso::Session.find_by(id: session["sso_session_id"]).try(:active?)
              warn { "Sso::Session inactive or missing. Logging out user" }
              warden.logout
              throw(:warden, :scope => scope, :reason => "Active Sso::Session not found")
            end
        end
      end
    end
  end
end
