class CreateSsoClients < ActiveRecord::Migration
  enable_extension 'uuid-ossp'

  def change
    create_table :sso_clients, id: :uuid do |t|
      t.uuid        "sso_session_id",  index: true
      t.references  "access_grant", index: true
      t.references  "access_token", index: true
      t.references  "application",  index: true
      t.string      "secret",       null: false, index: true
      t.string      "ip",           null: false
      t.string      "agent"
      t.string      "location"
      t.string      "device"
      t.datetime    "activity_at"
      t.timestamps  null: false
    end
  end
end
