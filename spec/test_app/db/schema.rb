# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151221071537) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "api_applications", force: :cascade do |t|
    t.string   "name"
    t.string   "api_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.text     "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id"
    t.string   "token",             null: false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        null: false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true, using: :btree
  add_index "oauth_access_tokens", ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id", using: :btree
  add_index "oauth_access_tokens", ["token"], name: "index_oauth_access_tokens_on_token", unique: true, using: :btree

  create_table "oauth_applications", force: :cascade do |t|
    t.string   "name",                      null: false
    t.text     "description"
    t.string   "uid",                       null: false
    t.string   "secret",                    null: false
    t.string   "app_uri",                   null: false
    t.text     "redirect_uri",              null: false
    t.text     "support_uri"
    t.string   "scopes",       default: "", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "pingback_uri"
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "sso_clients", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.uuid     "sso_session_id"
    t.integer  "access_grant_id"
    t.integer  "access_token_id"
    t.integer  "application_id"
    t.string   "ip"
    t.string   "agent"
    t.string   "location"
    t.string   "device"
    t.datetime "activity_at"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.string   "device_os"
    t.string   "device_os_version"
    t.string   "device_model"
  end

  add_index "sso_clients", ["access_grant_id"], name: "index_sso_clients_on_access_grant_id", using: :btree
  add_index "sso_clients", ["access_token_id"], name: "index_sso_clients_on_access_token_id", using: :btree
  add_index "sso_clients", ["application_id"], name: "index_sso_clients_on_application_id", using: :btree
  add_index "sso_clients", ["sso_session_id"], name: "index_sso_clients_on_sso_session_id", using: :btree

  create_table "sso_pingbacks", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sso_sessions", id: :uuid, default: "uuid_generate_v4()", force: :cascade do |t|
    t.integer  "access_grant_id"
    t.integer  "access_token_id"
    t.integer  "application_id"
    t.integer  "owner_id",        null: false
    t.string   "secret",          null: false
    t.datetime "activity_at",     null: false
    t.datetime "revoked_at"
    t.string   "revoke_reason"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "sso_sessions", ["access_grant_id"], name: "index_sso_sessions_on_access_grant_id", using: :btree
  add_index "sso_sessions", ["access_token_id"], name: "index_sso_sessions_on_access_token_id", using: :btree
  add_index "sso_sessions", ["application_id"], name: "index_sso_sessions_on_application_id", using: :btree
  add_index "sso_sessions", ["owner_id", "access_token_id", "application_id"], name: "one_access_token_per_owner", unique: true, where: "((revoked_at IS NULL) AND (access_token_id IS NOT NULL))", using: :btree
  add_index "sso_sessions", ["owner_id"], name: "index_sso_sessions_on_owner_id", using: :btree
  add_index "sso_sessions", ["revoke_reason"], name: "index_sso_sessions_on_revoke_reason", using: :btree
  add_index "sso_sessions", ["secret"], name: "index_sso_sessions_on_secret", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,    null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "lang",                   default: "EN"
    t.string   "phone"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
