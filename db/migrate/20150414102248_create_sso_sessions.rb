class CreateSsoSessions < ActiveRecord::Migration
  def change
    enable_extension 'uuid-ossp'

    create_table :sso_sessions, id: :uuid do |t|
      t.references  "access_grant", index: true
      t.references  "access_token", index: true
      t.references  "application",  index: true
      t.integer  "owner_id",        null: false
      t.string   "group_id",        null: false
      t.string   "secret",          null: false
      t.inet     "ip",              null: false
      t.string   "agent"
      t.string   "location"
      t.datetime "activity_at",     null: false
      t.datetime "revoked_at"
      t.string   "revoke_reason"
      t.timestamps
    end

    add_index :sso_sessions, [:owner_id, :access_token_id, :application_id], where: 'revoked_at IS NULL AND access_token_id IS NOT NULL', unique: true, name: :one_access_token_per_owner
    add_index :sso_sessions, :owner_id
    add_index :sso_sessions, :group_id
    add_index :sso_sessions, :secret
    add_index :sso_sessions, :ip
    add_index :sso_sessions, :revoke_reason
  end
end
