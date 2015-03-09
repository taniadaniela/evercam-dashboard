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

ActiveRecord::Schema.define() do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"
  enable_extension "postgis"

  create_table "access_rights", force: :cascade do |t|
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "token_id",                            null: false
    t.text     "right",                               null: false
    t.integer  "camera_id"
    t.integer  "grantor_id"
    t.integer  "status",                  default: 1, null: false
    t.integer  "snapshot_id"
    t.integer  "account_id"
    t.string   "scope",       limit: 100
  end

  add_index "access_rights", ["camera_id"], name: "access_rights_camera_id_index", using: :btree
  add_index "access_rights", ["token_id", "camera_id", "right"], name: "access_rights_token_id_camera_id_right_index", using: :btree
  add_index "access_rights", ["token_id"], name: "access_rights_token_id_index", using: :btree

  create_table "access_tokens", force: :cascade do |t|
    t.datetime "created_at", default: "now()", null: false
    t.datetime "updated_at", default: "now()", null: false
    t.datetime "expires_at",                   null: false
    t.boolean  "is_revoked",                   null: false
    t.integer  "user_id"
    t.integer  "client_id"
    t.text     "request",                      null: false
    t.text     "refresh"
    t.integer  "grantor_id"
  end

  add_index "access_tokens", ["client_id"], name: "ix_access_tokens_grantee_id", using: :btree
  add_index "access_tokens", ["request"], name: "ux_access_tokens_request", unique: true, using: :btree
  add_index "access_tokens", ["user_id"], name: "ix_access_tokens_grantor_id", using: :btree

  create_table "billing", force: :cascade do |t|
    t.integer  "user_id",    null: false
    t.integer  "timelapse"
    t.integer  "snapmail"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "camera_activities", id: false, force: :cascade do |t|
    t.integer  "id",              default: "nextval('camera_activities_id_seq'::regclass)", null: false
    t.integer  "camera_id",                                                                 null: false
    t.integer  "access_token_id"
    t.text     "action",                                                                    null: false
    t.datetime "done_at",                                                                   null: false
    t.inet     "ip"
    t.json     "extra"
  end

  add_index "camera_activities", ["camera_id", "done_at"], name: "camera_activities_camera_id_done_at_index", unique: true, using: :btree

  create_table "camera_endpoints", force: :cascade do |t|
    t.integer "camera_id"
    t.text    "scheme",    null: false
    t.text    "host",      null: false
    t.integer "port",      null: false
  end

  add_index "camera_endpoints", ["camera_id", "scheme", "host", "port"], name: "camera_endpoints_camera_id_scheme_host_port_index", unique: true, using: :btree

  create_table "camera_share_requests", force: :cascade do |t|
    t.integer  "camera_id",               null: false
    t.integer  "user_id",                 null: false
    t.string   "key",        limit: 100,  null: false
    t.string   "email",      limit: 250,  null: false
    t.integer  "status",                  null: false
    t.string   "rights",     limit: 1000, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  add_index "camera_share_requests", ["camera_id", "email"], name: "camera_share_requests_camera_id_email_index", using: :btree
  add_index "camera_share_requests", ["key"], name: "camera_share_requests_key_index", unique: true, using: :btree

  create_table "camera_shares", force: :cascade do |t|
    t.integer  "camera_id",             null: false
    t.integer  "user_id",               null: false
    t.integer  "sharer_id"
    t.string   "kind",       limit: 50, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "camera_shares", ["camera_id", "user_id"], name: "camera_shares_camera_id_user_id_index", unique: true, using: :btree
  add_index "camera_shares", ["camera_id"], name: "camera_shares_camera_id_index", using: :btree
  add_index "camera_shares", ["user_id"], name: "camera_shares_user_id_index", using: :btree

# Could not dump table "cameras" because of following StandardError
#   Unknown type 'geography(Point,4326)' for column 'location'

  create_table "clients", force: :cascade do |t|
    t.datetime "created_at",    default: "now()", null: false
    t.datetime "updated_at",    default: "now()", null: false
    t.text     "api_id",                          null: false
    t.text     "callback_uris",                                array: true
    t.text     "api_key"
    t.text     "name"
    t.text     "settings"
  end

  add_index "clients", ["api_id"], name: "ux_clients_exid", unique: true, using: :btree

  create_table "countries", force: :cascade do |t|
    t.datetime "created_at", default: "now()", null: false
    t.datetime "updated_at", default: "now()", null: false
    t.text     "iso3166_a2",                   null: false
    t.text     "name",                         null: false
  end

  add_index "countries", ["iso3166_a2"], name: "ux_countries_iso3166_a2", unique: true, using: :btree

  create_table "snapshots", id: false, force: :cascade do |t|
    t.integer  "id",         default: "nextval('snapshots_id_seq'::regclass)", null: false
    t.integer  "camera_id",                                                    null: false
    t.datetime "created_at",                                                   null: false
    t.text     "notes"
    t.binary   "data",                                                         null: false
    t.boolean  "is_public",  default: false,                                   null: false
  end

  add_index "snapshots", ["created_at", "camera_id"], name: "snapshots_created_at_camera_id_index", unique: true, using: :btree

  create_table "spatial_ref_sys", primary_key: "srid", force: :cascade do |t|
    t.string  "auth_name", limit: 256
    t.integer "auth_srid"
    t.string  "srtext",    limit: 2048
    t.string  "proj4text", limit: 2048
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at",       default: "now()", null: false
    t.datetime "updated_at",       default: "now()", null: false
    t.text     "firstname",                          null: false
    t.text     "lastname",                           null: false
    t.text     "username",                           null: false
    t.text     "password",                           null: false
    t.integer  "country_id",                         null: false
    t.datetime "confirmed_at"
    t.text     "email",                              null: false
    t.text     "reset_token"
    t.datetime "token_expires_at"
    t.text     "api_id"
    t.text     "api_key"
    t.boolean  "is_admin",         default: false,   null: false
    t.text     "billing_id"
  end

  add_index "users", ["api_id"], name: "users_api_id_index", unique: true, using: :btree
  add_index "users", ["country_id"], name: "ix_users_country_id", using: :btree
  add_index "users", ["email"], name: "ux_users_email", unique: true, using: :btree
  add_index "users", ["username"], name: "ux_users_username", unique: true, using: :btree

  create_table "vendor_models", force: :cascade do |t|
    t.datetime "created_at", default: "now()", null: false
    t.datetime "updated_at", default: "now()", null: false
    t.integer  "vendor_id",                    null: false
    t.text     "name",                         null: false
    t.json     "config",                       null: false
    t.text     "exid",       default: "",      null: false
    t.text     "jpg_url",    default: "",      null: false
    t.text     "h264_url",   default: "",      null: false
    t.text     "mjpg_url",   default: "",      null: false
  end

  add_index "vendor_models", ["exid"], name: "vendor_models_exid_index", unique: true, using: :btree
  add_index "vendor_models", ["vendor_id"], name: "ix_firmwares_vendor_id", using: :btree

  create_table "vendors", force: :cascade do |t|
    t.datetime "created_at", default: "now()", null: false
    t.datetime "updated_at", default: "now()", null: false
    t.text     "exid",                         null: false
    t.text     "known_macs",                   null: false, array: true
    t.text     "name",                         null: false
  end

  add_index "vendors", ["exid"], name: "ux_vendors_exid", unique: true, using: :btree
  add_index "vendors", ["known_macs"], name: "vx_vendors_known_macs", using: :gin

  create_table "webhooks", force: :cascade do |t|
    t.integer  "camera_id",  null: false
    t.integer  "user_id",    null: false
    t.text     "url",        null: false
    t.text     "exid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "access_rights", "access_tokens", column: "token_id", name: "access_rights_token_id_fkey", on_delete: :cascade
  add_foreign_key "access_rights", "cameras", name: "access_rights_camera_id_fkey", on_delete: :cascade
  add_foreign_key "access_rights", "users", column: "account_id", name: "access_rights_account_id_fkey", on_delete: :cascade
  add_foreign_key "access_rights", "users", column: "grantor_id", name: "access_rights_grantor_id_fkey"
  add_foreign_key "access_tokens", "clients", name: "fk_access_tokens_grantee_id", on_delete: :cascade
  add_foreign_key "access_tokens", "users", column: "grantor_id", name: "access_tokens_grantor_id_fkey", on_delete: :cascade
  add_foreign_key "access_tokens", "users", name: "fk_access_tokens_grantor_id", on_delete: :cascade
  add_foreign_key "billing", "users", name: "billing_user_id_fkey", on_delete: :cascade
  add_foreign_key "camera_activities", "access_tokens", name: "camera_activities_access_token_id_fkey", on_delete: :cascade
  add_foreign_key "camera_activities", "cameras", name: "camera_activities_camera_id_fkey", on_delete: :cascade
  add_foreign_key "camera_endpoints", "cameras", name: "camera_endpoints_camera_id_fkey", on_delete: :cascade
  add_foreign_key "camera_share_requests", "cameras", name: "camera_share_requests_camera_id_fkey", on_delete: :cascade
  add_foreign_key "camera_share_requests", "users", name: "camera_share_requests_user_id_fkey", on_delete: :cascade
  add_foreign_key "camera_shares", "cameras", name: "camera_shares_camera_id_fkey", on_delete: :cascade
  add_foreign_key "camera_shares", "users", column: "sharer_id", name: "camera_shares_sharer_id_fkey", on_delete: :nullify
  add_foreign_key "camera_shares", "users", name: "camera_shares_user_id_fkey", on_delete: :cascade
  add_foreign_key "cameras", "users", column: "owner_id", name: "fk_streams_owner_id", on_delete: :cascade
  add_foreign_key "cameras", "vendor_models", column: "model_id", name: "cameras_model_id_fkey"
  add_foreign_key "snapshots", "cameras", name: "snapshots_camera_id_fkey", on_delete: :cascade
  add_foreign_key "users", "countries", name: "fk_users_country_id", on_delete: :restrict
  add_foreign_key "vendor_models", "vendors", name: "fk_firmwares_vendor_id", on_delete: :cascade
  add_foreign_key "webhooks", "cameras", name: "webhooks_camera_id_fkey", on_delete: :cascade
  add_foreign_key "webhooks", "users", name: "webhooks_user_id_fkey", on_delete: :cascade
end
