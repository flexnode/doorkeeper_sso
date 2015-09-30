module Sso
  class Session < ActiveRecord::Base
    include ::Sso::Logging

    # FIXME: Not sure to use application or doorkeeper_application_id
    belongs_to :application, class_name: 'Doorkeeper::Application'  #,  inverse_of: :sso_sessions
    belongs_to :access_grant, class_name: 'Doorkeeper::AccessGrant' #, inverse_of: :sso_sessions
    belongs_to :access_token, class_name: 'Doorkeeper::AccessToken' #, inverse_of: :sso_sessions
    belongs_to :owner, class_name: 'User' #, inverse_of: :sso_sessions
    has_many   :clients, class_name: 'Sso::Client', foreign_key: :sso_session_id

    validates :owner_id, presence: true
    validates :revoke_reason, allow_blank: true, format: { with: /\A[a-z_]+\z/ }

    scope :active, -> { where(revoked_at: nil) }
    scope :master, -> { where(application_id: nil) }

    before_validation :ensure_secret
    before_validation :ensure_group_id
    before_validation :ensure_activity_at

    class << self
      def master_for(grant_id)
        active.find_by!(access_grant_id: grant_id)
      end

      def with_token_id(token_id)
        includes(:clients).where("sso_clients.access_token_id": token_id)
      end

      def with_grant_id(grant_id)
        includes(:clients).where("sso_clients.access_grant_id": grant_id)
      end

      def by_access_token(token)
        oauth_token = ::Doorkeeper::AccessToken.by_token(token)
        with_token_id(oauth_token.id)
      end

      def generate_master(user, options)
        attributes = ActionController::Parameters.new(options).permit(:ip, :agent, :location)
        sso_session = self.new( owner: user )
        sso_session.clients.build(attributes)
        debug { "Sso::Session::generate_master for #{user.inspect} - #{sso_session.inspect}" }
        sso_session.save!
        sso_session
      end

      def logout(sso_session_id)
        return false unless session = find_by_id(sso_session_id)
        session.logout
      end
    end

    def active?
      revoked_at.blank?
    end

    def logout
      clients.with_access_token.each do |c|
        c.access_token.revoke
      end
      update revoked_at: Time.current, revoke_reason: "logout"
    end

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
