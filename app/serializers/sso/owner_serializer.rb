module Sso
  class OwnerSerializer < ActiveModel::Serializer
    attributes :id, :name, :first_name, :last_name, :email, :lang
  end
end
