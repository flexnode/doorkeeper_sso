module Sso
  class Pingback
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
      return false unless sso_session = ::Sso::Session.find_by_id(session["sso_session_id"])
      ::Doorkeeper::Application.all.each do |app|
        debug { "Pingback Sso::Pingback for #{app.inspect}" }
        unless app.pingback_uri.blank?
          data = ::Sso::SessionSerializer.new(sso_session)
          debug { data.inspect }
          notifier = ::Sso::Notifier.new(app.pingback_uri, app.uid, app.secret, data)
          pingback.call
        end
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
