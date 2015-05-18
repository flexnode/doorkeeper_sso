module Sso
  class Session < ActiveRecord::Base
    include ::Sso::Logging
    # FIXME: Not sure to use application or doorkeeper_application_id
    belongs_to :application, class_name: 'Doorkeeper::Application'  #,  inverse_of: :sso_sessions
    belongs_to :access_grant, class_name: 'Doorkeeper::AccessGrant' #, inverse_of: :sso_sessions
    belongs_to :access_token, class_name: 'Doorkeeper::AccessToken' #, inverse_of: :sso_sessions
    belongs_to :owner, class_name: 'User' #, inverse_of: :sso_sessions

    validates :group_id, presence: true
    validates :owner_id, presence: true
    validates :ip, presence: true
    validates :secret, presence: true
    validates :access_token_id, uniqueness: { scope: [:owner_id, :revoked_at, :application_id], allow_blank: true }
    validates :revoke_reason, allow_blank: true, format: { with: /\A[a-z_]+\z/ }

    scope :active, -> { where(revoked_at: nil) }
    scope :master, -> { where(application_id: nil) }

    before_validation :ensure_secret
    before_validation :ensure_group_id
    before_validation :ensure_activity_at

    class << self
      def master_for(grant_id)
        active.master.find_by!(access_grant_id: grant_id)
      end

      def generate_master(user, options)
        relations = { owner: user }
        attributes = ActionController::Parameters.new(options).permit(:ip, :agent, :location)
        debug { "Sso::Session::generate_master for #{user.inspect} - #{attributes.inspect}" }
        create!(relations.merge(attributes))
      end

      def generate(user, access_token, options = {})
        master_sso_session = active.master.find_by!(owner_id: user.id, access_token_id: access_token.id)
        attributes = ActionController::Parameters.new(options).permit(:ip, :agent, :location)
        relations = { owner: user, application: access_token.application, access_token: access_token, group_id: master_sso_session.group_id }

        debug { "Sso::Session::generate for #{user.inspect} - #{access_token.inspect} - #{attributes.inspect}" }
        create!(relations.merge(attributes))
      end

      def logout(sso_session_id)
        if sso_session = find_by_id(sso_session_id)
          group_id = sso_session.group_id

          debug { "Sso::Session#logout - Revoking Session Group #{sso_session.group_id.inspect} from Session #{sso_session.id.inspect}" }
          count = where(group_id: group_id).update_all revoked_at: Time.current, revoke_reason: "logout"
          debug { "Successfully removed #{count.inspect} sessions." }
          count
        end
      end

      def update_master_with_grant(master_sso_session_id, oauth_grant)
        master_sso_session = active.master.find(master_sso_session_id)

        if master_sso_session.update_attribute(:access_grant_id, oauth_grant.id)
          debug { "#update_master_with_grant : #{master_sso_session.id} with Access Grant ID #{oauth_grant.id} which is #{oauth_grant.token}" }
        else
          error { "#update_master_with_grant : FAILED to update oauth_grant" }
        end
      end

      def update_master_with_access_token(grant_token, access_token)
        oauth_grant  = ::Doorkeeper::AccessGrant.by_token(grant_token)
        oauth_token  = ::Doorkeeper::AccessToken.by_token(access_token)
        return false if oauth_token.blank? or oauth_grant.blank?

        master_sso_session = active.master.find_by!(access_grant_id: oauth_grant.id)

        if master_sso_session.update_attributes(access_token_id: oauth_token.id, application_id: oauth_token.application_id)
          debug { "#register_access_token : #{master_sso_session.id} with Access Token ID #{oauth_token.id} which is #{oauth_token.token}" }
        else
          error { "#register_access_token : FAILED to update oauth_access_token_id" }
        end
        master_sso_session
      end
    end

    def create_session(token, options = {})
      create(access_token_id)
    end
    # def to_s
    #   ['Sso:Session', owner_id, ip, activity_at].join ', '
    # end

  private

    def ensure_secret
      self.secret ||= SecureRandom.uuid
    end

    def ensure_group_id
      self.group_id ||= SecureRandom.uuid
    end

    def ensure_activity_at
      self.activity_at ||= Time.current
    end
  end
end # Sso


# == Schema Information
# Schema version: 20150330031153
#
# Table name: sso_sessions
#
#  id              :uuid             not null, primary key
#  access_grant_id :integer
#  access_token_id :integer
#  application_id  :integer
#  owner_id        :integer          not null
#  group_id        :string           not null
#  secret          :string           not null
#  ip              :inet             not null
#  agent           :string
#  location        :string
#  activity_at     :datetime         not null
#  revoked_at      :datetime
#  revoke_reason   :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_sso_sessions_on_access_grant_id  (access_grant_id)
#  index_sso_sessions_on_access_token_id  (access_token_id)
#  index_sso_sessions_on_application_id   (application_id)
#  index_sso_sessions_on_group_id         (group_id)
#  index_sso_sessions_on_ip               (ip)
#  index_sso_sessions_on_owner_id         (owner_id)
#  index_sso_sessions_on_revoke_reason    (revoke_reason)
#  index_sso_sessions_on_secret           (secret)
#  one_access_token_per_owner             (owner_id,access_token_id,application_id) UNIQUE
#
