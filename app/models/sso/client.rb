module Sso
  class Client < ActiveRecord::Base
    include ::Sso::Logging

    belongs_to :sso_session, class_name: 'Sso::Session', inverse_of: :sso_clients
    belongs_to :application, class_name: 'Doorkeeper::Application'  #,  inverse_of: :sso_sessions
    belongs_to :access_grant, class_name: 'Doorkeeper::AccessGrant' #, inverse_of: :sso_sessions
    belongs_to :access_token, class_name: 'Doorkeeper::AccessToken' #, inverse_of: :sso_sessions


    validates :ip, presence: true
  end
end
