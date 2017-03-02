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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(version: 20121104095920) do

  create_table "accounts", force: true do |t|
    t.integer "contractor_id", null: false
    t.float   "balance",       null: false
    t.float   "min_balance",   null: false
    t.float   "max_balance",   null: false
    t.float   "locked_funds",  null: false
  end

  create_table "active_admin_comments", force: true do |t|
    t.string   "resource_id",   null: false
    t.string   "resource_type", null: false
    t.integer  "author_id"
    t.string   "author_type"
    t.text     "body"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "namespace"
  end

  add_index "active_admin_comments", ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
  add_index "active_admin_comments", ["namespace"], name: "index_active_admin_comments_on_namespace"
  add_index "active_admin_comments", ["resource_type", "resource_id"], name: "index_admin_notes_on_resource_type_and_resource_id"

  create_table "admin_users", force: true do |t|
    t.string   "email",                  default: "",   null: false
    t.string   "encrypted_password",     default: "",   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "group",                  default: 0
    t.boolean  "enabled",                default: true
  end

  add_index "admin_users", ["email"], name: "index_admin_users_on_email", unique: true
  add_index "admin_users", ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true

  create_table "cdrs", force: true do |t|
    t.integer  "customer_id"
    t.integer  "vendor_id"
    t.integer  "customer_acc_id"
    t.integer  "vendor_acc_id"
    t.integer  "customer_auth_id"
    t.integer  "destination_id"
    t.integer  "dialpeer_id"
    t.integer  "orig_gw_id"
    t.integer  "term_gw_id"
    t.integer  "routing_group_id"
    t.integer  "rateplan_id"
    t.decimal  "destination_rate"
    t.decimal  "destination_fee"
    t.decimal  "dialpeer_rate"
    t.decimal  "dialpeer_fee"
    t.string   "time_limit",              limit: nil
    t.integer  "disconnect_code"
    t.string   "disconnect_reason",       limit: nil
    t.integer  "disconnect_initiator_id"
    t.float    "customer_price"
    t.float    "vendor_price"
    t.integer  "duration"
    t.boolean  "success"
    t.boolean  "vendor_billed",                          default: false
    t.boolean  "customer_billed",                        default: false
    t.float    "profit"
    t.string   "dst_prefix_in",           limit: nil
    t.string   "dst_prefix_out",          limit: nil
    t.string   "src_prefix_in",           limit: nil
    t.string   "src_prefix_out",          limit: nil
    t.datetime "time_start"
    t.datetime "time_connect"
    t.datetime "time_end"
    t.string   "sign_orig_ip",            limit: nil
    t.integer  "sign_orig_port",          limit: 2
    t.string   "sign_orig_local_ip",      limit: nil
    t.integer  "sign_orig_local_port",    limit: 2
    t.string   "sign_term_ip",            limit: nil
    t.integer  "sign_term_port",          limit: 2
    t.string   "sign_term_local_ip",      limit: nil
    t.integer  "sign_term_local_port",    limit: 2
    t.string   "orig_call_id",            limit: nil
    t.string   "term_call_id",            limit: nil
  end

  create_table "contractors", force: true do |t|
    t.string  "name",     limit: nil
    t.boolean "enabled"
    t.boolean "vendor"
    t.boolean "customer"
  end

  create_table "customers_auth", force: true do |t|
    t.integer "customer_id",                                         null: false
    t.integer "routing_group_id",                                    null: false
    t.integer "rateplan_id",                                         null: false
    t.boolean "enabled",                           default: true, null: false
    t.string  "ip",                 limit: nil
    t.string  "prefix",             limit: nil
    t.integer "account_id"
    t.integer "gateway_id",                                          null: false
    t.string  "src_rewrite_rule",   limit: nil
    t.string  "src_rewrite_result", limit: nil
    t.string  "dst_rewrite_rule",   limit: nil
    t.string  "dst_rewrite_result", limit: nil
  end

  create_table "destinations", force: true do |t|
    t.boolean "enabled",                                     null: false
    t.string  "prefix",      limit: nil,                  null: false
    t.integer "rateplan_id",                                 null: false
    t.decimal "rate",                       default: 0.0, null: false
    t.decimal "connect_fee",                default: 0.0
  end

  add_index "destinations", ["rateplan_id"], name: "destinations_prefix_range_rateplan_id_idx"

  create_table "dialpeers", force: true do |t|
    t.boolean "enabled",                           null: false
    t.string  "prefix",             limit: nil, null: false
    t.string  "src_rewrite_rule",   limit: nil
    t.string  "dst_rewrite_rule",   limit: nil
    t.float   "acd_limit"
    t.float   "asr_limit",                         null: false
    t.integer "gateway_id",                        null: false
    t.integer "routing_group_id",                  null: false
    t.decimal "rate",                              null: false
    t.decimal "connect_fee",                       null: false
    t.integer "vendor_id",                         null: false
    t.integer "account_id",                        null: false
    t.string  "src_rewrite_result", limit: nil
    t.string  "dst_rewrite_result", limit: nil
  end

  create_table "disconnect_codes", force: true do |t|
    t.integer "code",             null: false
    t.boolean "success",          null: false
    t.boolean "successnozerolen", null: false
  end

  create_table "disconnect_initiators", id: false, force: true do |t|
    t.integer "id",                  null: false
    t.string  "name", limit: nil
  end

  create_table "gateways", force: true do |t|
    t.string  "host",                      limit: nil,                    null: false
    t.integer "port"
    t.string  "src_rewrite_rule",          limit: nil
    t.string  "dst_rewrite_rule",          limit: nil
    t.float   "acd_limit"
    t.float   "asr_limit"
    t.boolean "enabled",                                                     null: false
    t.string  "name",                      limit: nil,                    null: false
    t.boolean "term_auth_enabled",                        default: false, null: false
    t.string  "term_auth_user",            limit: nil
    t.string  "term_auth_pwd",             limit: nil
    t.string  "term_outbound_proxy",       limit: nil
    t.string  "term_next_hop_ip",          limit: nil
    t.integer "term_next_hop_port",        limit: 2
    t.boolean "term_next_hop_for_replies",                default: false, null: false
    t.boolean "term_use_outbound_proxy",                  default: false, null: false
    t.integer "contractor_id",                                               null: false
    t.boolean "allow_termination",                        default: true,  null: false
    t.boolean "allow_origination",                        default: true,  null: false
    t.boolean "anonymize_sdp",                            default: true,  null: false
    t.boolean "proxy_media",                              default: false, null: false
    t.boolean "transparent_seqno",                        default: false, null: false
    t.boolean "transparent_ssrc",                         default: false, null: false
    t.boolean "sst_enabled",                              default: false
    t.integer "sst_minimum_timer",                        default: 50,    null: false
    t.integer "sst_maximum_timer",                        default: 50,    null: false
    t.boolean "sst_accept501",                            default: true,  null: false
    t.integer "session_refresh_method_id",                default: 3,     null: false
    t.integer "sst_session_expires",                      default: 50
    t.boolean "term_force_outbound_proxy",                default: false, null: false
  end

  create_table "payments", force: true do |t|
    t.integer  "account_id",                null: false
    t.decimal  "amount",                    null: false
    t.string   "notes",      limit: nil
    t.datetime "created_at",                null: false
  end

  create_table "rateplans", force: true do |t|
    t.string "name", limit: nil
  end

  create_table "routing_groups", force: true do |t|
    t.string "name",    limit: nil, null: false
    t.string "sorting", limit: nil
  end

  create_table "session_refresh_methods", force: true do |t|
    t.string "value", limit: nil, null: false
    t.string "name",  limit: nil
  end

  create_table "versions", force: true do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.string   "ip"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
