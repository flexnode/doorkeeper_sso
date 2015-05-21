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

      def generate(user, access_token, options = {})
        master_sso_session = active.find_by!(owner_id: user.id)

        attributes = ActionController::Parameters.new(options).permit(:ip, :agent, :location)
        relations = { application: access_token.application, access_token: access_token }

        debug { "Sso::Session::generate for #{user.inspect} - #{access_token.inspect} - #{attributes.inspect}" }

        if client = master_sso_session_id.clients.find_by(access_token_id: access_token.id)
          client.update_columns(attributes)
        else
          master_sso_session.clients.create!(relations.merge(attributes))
        end
        master_sso_session
      end

      def logout(sso_session_id)
        session = find_by_id(sso_session_id)
        return false if session.blank?
        session.logout
      end

      # def update_master_with_grant(master_sso_session_id, oauth_grant)
      #   master_sso_session = active.find(master_sso_session_id)

      #   if master_sso_session.update_attribute(:access_grant_id, oauth_grant.id)
      #     debug { "#update_master_with_grant : #{master_sso_session.id} with Access Grant ID #{oauth_grant.id} which is #{oauth_grant.token}" }
      #   else
      #     error { "#update_master_with_grant : FAILED to update oauth_grant" }
      #   end
      # end

      # def update_master_with_access_token(grant_token, access_token)
      #   oauth_grant  = ::Doorkeeper::AccessGrant.by_token(grant_token)
      #   oauth_token  = ::Doorkeeper::AccessToken.by_token(access_token)
      #   return false if oauth_token.blank? or oauth_grant.blank?

      #   master_sso_session = active.with_grant_id(oauth_grant.id).first

      #   if master_sso_session.update_attributes(access_token_id: oauth_token.id, application_id: oauth_token.application_id)
      #     debug { "#register_access_token : #{master_sso_session.id} with Access Token ID #{oauth_token.id} which is #{oauth_token.token}" }
      #   else
      #     error { "#register_access_token : FAILED to update oauth_access_token_id" }
      #   end
      #   master_sso_session
      # end
    end

    def create_session(token, options = {})
      create(access_token_id)
    end
    # def to_s
    #   ['Sso:Session', owner_id, ip, activity_at].join ', '
    # end

    def active?
      revoked_at.blank?
    end

    def logout
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
