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

  create_table "access_rights", force: true do |t|
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
    t.integer  "token_id",               null: false
    t.text     "right",                  null: false
    t.integer  "camera_id",              null: false
    t.integer  "grantor_id"
    t.integer  "status",     default: 1, null: false
  end

  add_index "access_rights", ["camera_id"], name: "access_rights_camera_id_index", using: :btree
  add_index "access_rights", ["token_id", "camera_id", "right"], name: "access_rights_token_id_camera_id_right_index", unique: true, using: :btree
  add_index "access_rights", ["token_id"], name: "access_rights_token_id_index", using: :btree

  create_table "access_tokens", force: true do |t|
    t.datetime "created_at", default: "now()", null: false
    t.datetime "updated_at", default: "now()", null: false
    t.datetime "expires_at",                   null: false
    t.boolean  "is_revoked",                   null: false
    t.integer  "user_id"
    t.integer  "client_id"
    t.text     "request",                      null: false
    t.text     "refresh"
  end

  add_index "access_tokens", ["client_id"], name: "ix_access_tokens_grantee_id", using: :btree
  add_index "access_tokens", ["request"], name: "ux_access_tokens_request", unique: true, using: :btree
  add_index "access_tokens", ["user_id"], name: "ix_access_tokens_grantor_id", using: :btree

  create_table "camera_activities", force: true do |t|
    t.integer  "camera_id",       null: false
    t.integer  "access_token_id"
    t.text     "action",          null: false
    t.datetime "done_at",         null: false
    t.inet     "ip"
  end

  add_index "camera_activities", ["camera_id", "done_at"], name: "camera_activities_camera_id_done_at_index", unique: true, using: :btree

  create_table "camera_endpoints", force: true do |t|
    t.integer "camera_id"
    t.text    "scheme",    null: false
    t.text    "host",      null: false
    t.integer "port",      null: false
  end

  add_index "camera_endpoints", ["camera_id", "scheme", "host", "port"], name: "camera_endpoints_camera_id_scheme_host_port_index", unique: true, using: :btree

  create_table "camera_shares", force: true do |t|
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

  create_table "cameras", force: true do |t|
    t.datetime "created_at",               default: "now()", null: false
    t.datetime "updated_at",               default: "now()", null: false
    t.text     "exid",                                       null: false
    t.integer  "firmware_id"
    t.integer  "owner_id",                                   null: false
    t.boolean  "is_public",                                  null: false
    t.json     "config",                                     null: false
    t.text     "name",                                       null: false
    t.datetime "last_polled_at"
    t.boolean  "is_online"
    t.text     "timezone"
    t.datetime "last_online_at"
    t.integer  "location"
    t.macaddr  "mac_address"
  end

  add_index "cameras", ["exid"], name: "ux_streams_name", unique: true, using: :btree
  add_index "cameras", ["mac_address"], name: "cameras_mac_address_index", using: :btree
  add_index "cameras", ["owner_id"], name: "ix_streams_owner_id", using: :btree

  create_table "clients", force: true do |t|
    t.datetime "created_at",    default: "now()", null: false
    t.datetime "updated_at",    default: "now()", null: false
    t.text     "exid",                            null: false
    t.text     "callback_uris",                                array: true
    t.text     "secret"
    t.text     "name"
  end

  add_index "clients", ["exid"], name: "ux_clients_exid", unique: true, using: :btree

  create_table "countries", force: true do |t|
    t.datetime "created_at", default: "now()", null: false
    t.datetime "updated_at", default: "now()", null: false
    t.text     "iso3166_a2",                   null: false
    t.text     "name",                         null: false
  end

  add_index "countries", ["iso3166_a2"], name: "ux_countries_iso3166_a2", unique: true, using: :btree

  create_table "firmwares", force: true do |t|
    t.datetime "created_at",   default: "now()", null: false
    t.datetime "updated_at",   default: "now()", null: false
    t.integer  "vendor_id",                      null: false
    t.text     "name",                           null: false
    t.json     "config",                         null: false
    t.text     "known_models",                   null: false, array: true
  end

  add_index "firmwares", ["vendor_id"], name: "ix_firmwares_vendor_id", using: :btree

  create_table "snapshots", force: true do |t|
    t.integer  "camera_id",  null: false
    t.datetime "created_at", null: false
    t.text     "notes"
    t.binary   "data",       null: false
  end

  add_index "snapshots", ["created_at", "camera_id"], name: "snapshots_created_at_camera_id_index", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.datetime "created_at",       default: "now()", null: false
    t.datetime "updated_at",       default: "now()", null: false
    t.text     "forename",                           null: false
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
  end

  add_index "users", ["country_id"], name: "ix_users_country_id", using: :btree
  add_index "users", ["email"], name: "ux_users_email", unique: true, using: :btree
  add_index "users", ["username"], name: "ux_users_username", unique: true, using: :btree

  create_table "vendors", force: true do |t|
    t.datetime "created_at", default: "now()", null: false
    t.datetime "updated_at", default: "now()", null: false
    t.text     "exid",                         null: false
    t.text     "known_macs",                   null: false, array: true
    t.text     "name",                         null: false
  end

  add_index "vendors", ["exid"], name: "ux_vendors_exid", unique: true, using: :btree
  add_index "vendors", ["known_macs"], name: "vx_vendors_known_macs", using: :gin

end
