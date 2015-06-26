module Sso
  module Warden
    module Support
      extend ActiveSupport::Concern
      include ::Sso::Logging

      included do
        attr_reader :user, :warden, :options
        delegate :request, to: :warden
        delegate :params, to: :request
      end

      module ClassMethods
        def to_proc
          proc do |user, warden, options|
            new(user, warden, options).call
          end
        end
      end

      def initialize(user, warden, options)
        @user, @warden, @options = user, warden, options
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
