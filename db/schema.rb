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

ActiveRecord::Schema.define(version: 20130615013346) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "adjective_circles", force: true do |t|
    t.string   "name_pair"
    t.string   "version"
    t.float    "size_weight"
    t.float    "size_sd"
    t.float    "size_mean"
    t.float    "distance_weight"
    t.float    "distance_sd"
    t.float    "distance_mean"
    t.float    "overlap_weight"
    t.float    "overlap_sd"
    t.float    "overlap_mean"
    t.string   "maps_to"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "authentications", force: true do |t|
    t.integer  "user_id"
    t.string   "provider"
    t.string   "uid"
    t.string   "oauth_token"
    t.datetime "oauth_expires_at"
    t.string   "email"
    t.string   "name"
    t.string   "display_name"
    t.string   "description"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "timezone"
    t.string   "locale"
    t.string   "image"
    t.string   "gender"
    t.date     "date_of_birth"
    t.date     "member_since"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "data_source_settings", force: true do |t|
    t.integer  "user_id"
    t.integer  "data_source_id"
    t.string   "auth_token"
    t.datetime "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_sources", force: true do |t|
    t.string   "name"
    t.string   "description"
    t.string   "logo_url"
    t.string   "end_point_url"
    t.string   "api_key"
    t.string   "api_secret"
    t.string   "retention_policy"
    t.string   "rate_limit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "data_sources_tracker_types", id: false, force: true do |t|
    t.integer "data_source_id"
    t.integer "tracker_type_id"
  end

  create_table "definitions", force: true do |t|
    t.string   "name"
    t.text     "stages"
    t.text     "instructions"
    t.text     "end_remarks"
    t.string   "icon"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.text     "score_names"
    t.text     "calculates"
    t.string   "result_view"
  end

  create_table "elements", force: true do |t|
    t.string   "name"
    t.string   "version"
    t.float    "standard_deviation"
    t.float    "mean"
    t.float    "weight_extraversion"
    t.float    "weight_conscientiousness"
    t.float    "weight_neuroticism"
    t.float    "weight_openness"
    t.float    "weight_agreeableness"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "games", force: true do |t|
    t.datetime "date_taken"
    t.integer  "definition_id"
    t.integer  "user_id"
    t.text     "stages"
    t.integer  "stage_completed"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "status"
    t.string   "calling_ip"
  end

  create_table "images", force: true do |t|
    t.string   "name"
    t.text     "elements"
    t.string   "primary_color"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "oauth_access_grants", force: true do |t|
    t.integer  "resource_owner_id", null: false
    t.integer  "application_id",    null: false
    t.string   "token",             null: false
    t.integer  "expires_in",        null: false
    t.string   "redirect_uri",      null: false
    t.datetime "created_at",        null: false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], name: "index_oauth_access_grants_on_token", unique: true, using: :btree

  create_table "oauth_access_tokens", force: true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    null: false
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

  create_table "oauth_applications", force: true do |t|
    t.string   "name",         null: false
    t.string   "uid",          null: false
    t.string   "secret",       null: false
    t.string   "redirect_uri", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "oauth_applications", ["uid"], name: "index_oauth_applications_on_uid", unique: true, using: :btree

  create_table "personalities", force: true do |t|
    t.integer  "profile_description_id"
    t.integer  "user_id"
    t.integer  "game_id"
    t.text     "big5_score"
    t.text     "holland6_score"
    t.string   "big5_dimension"
    t.string   "holland6_dimension"
    t.string   "big5_low"
    t.string   "big5_high"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "profile_descriptions", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "one_liner"
    t.text     "bullet_description"
    t.string   "big5_dimension"
    t.string   "holland6_dimension"
    t.string   "code"
    t.string   "logo_url"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.string   "display_id"
  end

  create_table "recommendations", force: true do |t|
    t.string   "big5_dimension", null: false
    t.string   "link_type"
    t.string   "icon_url"
    t.string   "sentence"
    t.string   "link_title"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommendations", ["big5_dimension"], name: "index_recommendations_on_big5_dimension", using: :btree

  create_table "results", force: true do |t|
    t.integer  "game_id",              null: false
    t.text     "event_log"
    t.text     "intermediate_results"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "aggregate_results"
  end

  add_index "results", ["game_id"], name: "index_results_on_game_id", unique: true, using: :btree

  create_table "tracker_settings", force: true do |t|
    t.integer  "user_id"
    t.string   "data_methods",   array: true
    t.hstore   "config"
    t.hstore   "privacy_config"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tracker_types", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.boolean  "isCalculated"
    t.text     "schema"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "trackers", force: true do |t|
    t.integer  "tracker_type_id"
    t.integer  "user_id"
    t.datetime "date_started"
    t.datetime "date_ended"
    t.hstore   "data"
    t.datetime "date_updated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",           default: "",    null: false
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "password_digest", default: "",    null: false
    t.boolean  "admin",           default: false, null: false
    t.boolean  "guest",           default: false, null: false
    t.string   "name"
    t.string   "display_name"
    t.string   "description"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "timezone"
    t.string   "locale"
    t.string   "image"
    t.string   "gender"
    t.date     "date_of_birth"
    t.string   "handedness"
    t.string   "orientation"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "vs_database_diagrams", id: false, force: true do |t|
    t.string   "name",     limit: 80
    t.text     "diadata"
    t.string   "comment",  limit: 1022
    t.text     "preview"
    t.string   "lockinfo", limit: 80
    t.datetime "locktime"
    t.string   "version",  limit: 80
  end

end
