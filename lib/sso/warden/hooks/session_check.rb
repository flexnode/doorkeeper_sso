module Sso
  module Warden
    module Hooks
      class SessionCheck
        include ::Sso::Logging

        attr_reader :user, :warden, :options
        delegate :request, to: :warden
        delegate :params, to: :request

        def self.to_proc
          proc do |user, warden, options|
            new(user, warden, options).call
          end
        end

        def initialize(user, warden, options)
          @user, @warden, @options = user, warden, options
        end

        def call
          debug { "Starting hook after user is fetched into the session" }

          # Infinite loop with BeforeLogout - before logout runs this too
          unless logged_in? && Sso::Session.find_by_id(session["sso_session_id"]).try(:active?)
            warden.logout(scope)
            throw(:warden, :scope => scope, :reason => "Sso::Session INACTIVE")
          end
        end

        def scope
          scope = options[:scope]
        end

        def session
          warden.session(scope)
        end

        def logged_in?
          warden.authenticated?(scope) && session && user
        end
      end
    end
  end
end
