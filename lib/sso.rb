require "sso/engine"
require "sso/logging"
require "sso/warden/support"
require "sso/warden/hooks/create_master_session"
require "sso/warden/hooks/before_logout"
require "sso/warden/hooks/session_check"
require "sso/doorkeeper/access_grant_mixin"
require "sso/doorkeeper/access_token_mixin"
require "sso/doorkeeper/application_mixin"
require "sso/doorkeeper/application_controller_mixin"
require "sso/doorkeeper/authorization"
require "sso/doorkeeper/oauth"


module Sso
  def self.table_name_prefix
    'sso_'
  end
end

