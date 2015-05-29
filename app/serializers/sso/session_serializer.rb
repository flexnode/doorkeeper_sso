module Sso
  class SessionSerializer < ActiveModel::Serializer
    attributes :id, :active?, :revoked_at, :revoke_reason

    belongs_to :owner, serializer: Sso::OwnerSerializer
  end
end
