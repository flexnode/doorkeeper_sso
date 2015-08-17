require "sso/engine"
require "sso/logging"
require "sso/warden/support"
require "sso/warden/hooks/create_master_session"
require "sso/warden/hooks/before_logout"
require "sso/warden/hooks/session_check"
require "sso/doorkeeper/access_grant_mixin"
require "sso/doorkeeper/access_token_mixin"
require "sso/doorkeeper/application_mixin"
require "sso/doorkeeper/authorizations_controller_mixin"
require "sso/doorkeeper/tokens_controller_mixin"


module Sso
  def self.table_name_prefix
    'sso_'
  end
end
