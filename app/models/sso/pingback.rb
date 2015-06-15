require_dependency "api_auth"
require_dependency "rest-client"

module Sso
  class Pingback

    def call
      ::Doorkeeper::Application.all.each do |app|
      unless app.pingback_uri.blank?
        notifier = ::Sso::Notifier.new(app.pingback_uri, app.uid, app.secret, ::Sso::SessionSerializer.new(self))
        pingback.call
      end
    end
  end
end
