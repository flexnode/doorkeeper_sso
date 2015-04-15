module Sso
  module Warden
    module Hooks
      class BeforeLogout
        include ::Sso::Logging

        attr_reader :user, :warden, :options
        delegate :request, to: :warden
        delegate :params, to: :request
        delegate :session, to: :request

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
          if warden.authenticated?(:user) && (session = warden.session(:user))
            debug { 'Destroy all Sso::Session groups before logout' }
            debug { session.inspect }
            Sso::Session.logout(session["sso_session_id"])
            #Passports.logout passport_id: params['passport_id'], provider_passport_id: session['sso_session_id']
          end
        end
      end
    end
  end
end
