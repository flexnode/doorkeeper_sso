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
            new(user: user, warden: warden, options: options).call
          end
        end

        def initialize(user:, warden:, options:)
          @user, @warden, @options = user, warden, options
        end

        def call
          # Only run if user is logged in
          if logged_in?
            debug { "Logout Sso::Session - #{session["sso_session_id"]}" }
            Sso::Session.logout(session["sso_session_id"])
          end
        end

        def scope
          scope = options[:scope]
        end

        def session
          warden.session(scope)
        end

        def logged_in?
          warden.authenticated?(:user) && session
        end
      end
    end
  end
end
