require "sso/engine"
require "sso/logging"
require "doorkeeper/authorizations_controller_mixin"
require "doorkeeper/tokens_controller_mixin"

require "sso/warden/hooks/after_authentication"
require "sso/warden/hooks/before_logout"

module Sso
  def self.table_name_prefix
    'sso_'
  end
end
