module Sso
  class ClientSerializer < ActiveModel::Serializer
    delegate :id, :active?, :revoked_at, :revoke_reason, :secret, to: :session

    attribute  :id, :key => :client_id
    attributes :id, :active?, :revoked_at, :revoke_reason, :secret, :random_token


    belongs_to :owner, serializer: Sso::OwnerSerializer # WTH : hack to load owner using serializer

    def session
      object.session
    end

    # WTH : i dont get why i have to do loops to customize my json output
    def owner
      session.owner
    end
  end
end
