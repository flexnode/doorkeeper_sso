require "sso/engine"
require "sso/logging"
require "sso/warden/hooks/after_authentication"
require "sso/warden/hooks/before_logout"
require "sso/warden/hooks/session_check"
require "sso/doorkeeper/authorizations_controller_mixin"
require "sso/doorkeeper/tokens_controller_mixin"


module Sso
  def self.table_name_prefix
    'sso_'
  end
end
