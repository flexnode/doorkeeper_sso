module Sso
  module Warden
    module Hooks
      class BeforeLogout
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
          # Only run if user is logged in
          if logged_in?
            debug { "#BeforeLogout Sso::Session - #{session["sso_session_id"]}" }
            debug { "user is #{user.inspect}" }
            ::Sso::Session.logout(session["sso_session_id"])
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
