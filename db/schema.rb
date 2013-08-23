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

ActiveRecord::Schema.define(version: 20130823004720) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "activities", force: true do |t|
    t.integer  "user_id",         null: false
    t.date     "date_recorded",   null: false
    t.integer  "type_id"
    t.string   "name"
    t.hstore   "data"
    t.hstore   "goals"
    t.text     "daily_breakdown"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["date_recorded"], name: "index_activities_on_date_recorded", using: :btree
  add_index "activities", ["provider"], name: "index_activities_on_provider", using: :btree
  add_index "activities", ["user_id"], name: "index_activities_on_user_id", using: :btree

  create_table "admins", force: true do |t|
    t.string   "email"
    t.string   "password_digest"
    t.datetime "created_at"
    t.datetime "updated_at"
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
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.string   "oauth_secret"
    t.boolean  "is_activated"
    t.datetime "last_accessed"
    t.hstore   "last_synchronized"
    t.hstore   "profile"
    t.string   "sync_status",       default: "not_synchronized"
    t.text     "last_error"
    t.datetime "oauth_refresh_at"
    t.boolean  "expires"
    t.text     "permissions"
  end

  add_index "authentications", ["provider"], name: "index_authentications_on_provider", using: :btree
  add_index "authentications", ["sync_status"], name: "index_authentications_on_sync_status", using: :btree
  add_index "authentications", ["uid"], name: "index_authentications_on_uid", using: :btree
  add_index "authentications", ["user_id"], name: "index_authentications_on_user_id", using: :btree

  create_table "career_recommendations", force: true do |t|
    t.integer  "profile_description_id"
    t.string   "careers",                array: true
    t.string   "skills",                 array: true
    t.string   "tools",                  array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "definitions", force: true do |t|
    t.string   "name"
    t.text     "stages"
    t.text     "instructions"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.text     "recipe_names"
    t.text     "persist_as_results"
    t.string   "unique_name"
  end

  add_index "definitions", ["unique_name"], name: "index_definitions_on_unique_name", unique: true, using: :btree

  create_table "emotion_descriptions", force: true do |t|
    t.string   "name",          null: false
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "friendly_name"
    t.text     "description"
  end

  add_index "emotion_descriptions", ["name"], name: "index_emotion_descriptions_on_name", using: :btree

  create_table "emotion_factor_recommendations", force: true do |t|
    t.string   "name",                           null: false
    t.string   "recommendations_per_percentile",              array: true
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "emotion_factor_recommendations", ["name"], name: "index_emotion_factor_recommendations_on_name", using: :btree

  create_table "foods", force: true do |t|
    t.integer  "user_id",       null: false
    t.date     "date_recorded", null: false
    t.hstore   "data"
    t.hstore   "goals"
    t.text     "details"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "foods", ["date_recorded"], name: "index_foods_on_date_recorded", using: :btree
  add_index "foods", ["provider"], name: "index_foods_on_provider", using: :btree
  add_index "foods", ["user_id"], name: "index_foods_on_user_id", using: :btree

  create_table "friend_surveys", force: true do |t|
    t.integer  "game_id"
    t.text     "answers"
    t.string   "calling_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friend_surveys", ["game_id"], name: "index_friend_surveys_on_game_id", using: :btree

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
    t.text     "event_log"
    t.text     "last_error"
    t.string   "name"
  end

  add_index "games", ["name"], name: "index_games_on_name", using: :btree
  add_index "games", ["user_id"], name: "index_games_on_user_id", using: :btree

  create_table "images", force: true do |t|
    t.string   "name"
    t.text     "elements"
    t.string   "primary_color"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "images", ["name"], name: "index_images_on_name", using: :btree

  create_table "measurements", force: true do |t|
    t.integer  "user_id",       null: false
    t.date     "date_recorded", null: false
    t.hstore   "data"
    t.hstore   "goals"
    t.text     "details"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "measurements", ["date_recorded"], name: "index_measurements_on_date_recorded", using: :btree
  add_index "measurements", ["provider"], name: "index_measurements_on_provider", using: :btree
  add_index "measurements", ["user_id"], name: "index_measurements_on_user_id", using: :btree

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

  create_table "preferences", force: true do |t|
    t.integer  "user_id"
    t.string   "type"
    t.hstore   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "preorders", force: true do |t|
    t.integer  "user_id"
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

  add_index "profile_descriptions", ["big5_dimension"], name: "index_profile_descriptions_on_big5_dimension", using: :btree
  add_index "profile_descriptions", ["holland6_dimension"], name: "index_profile_descriptions_on_holland6_dimension", using: :btree

  create_table "reaction_time_descriptions", force: true do |t|
    t.string   "big5_dimension",     null: false
    t.string   "speed_archetype",    null: false
    t.text     "description"
    t.text     "bullet_description"
    t.string   "display_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "reaction_time_descriptions", ["big5_dimension"], name: "index_reaction_time_descriptions_on_big5_dimension", using: :btree
  add_index "reaction_time_descriptions", ["speed_archetype"], name: "index_reaction_time_descriptions_on_speed_archetype", using: :btree

  create_table "recommendations", force: true do |t|
    t.string   "big5_dimension", null: false
    t.string   "link_type"
    t.string   "icon_url"
    t.string   "sentence"
    t.string   "link_title"
    t.string   "link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "display_id"
  end

  add_index "recommendations", ["big5_dimension"], name: "index_recommendations_on_big5_dimension", using: :btree

  create_table "results", force: true do |t|
    t.integer  "game_id",              null: false
    t.text     "event_log"
    t.text     "intermediate_results"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.text     "aggregate_results"
    t.hstore   "score"
    t.text     "calculations"
    t.integer  "user_id"
    t.datetime "time_played"
    t.datetime "time_calculated"
    t.string   "analysis_version"
    t.string   "type"
  end

  add_index "results", ["game_id"], name: "index_results_on_game_id", using: :btree
  add_index "results", ["score"], name: "index_results_on_score", using: :gin
  add_index "results", ["time_played"], name: "index_results_on_time_played", using: :btree
  add_index "results", ["type"], name: "index_results_on_type", using: :btree
  add_index "results", ["user_id"], name: "index_results_on_user_id", using: :btree

  create_table "sleeps", force: true do |t|
    t.integer  "user_id",        null: false
    t.date     "date_recorded",  null: false
    t.hstore   "data"
    t.hstore   "goals"
    t.text     "sleep_activity"
    t.string   "provider"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sleeps", ["date_recorded"], name: "index_sleeps_on_date_recorded", using: :btree
  add_index "sleeps", ["provider"], name: "index_sleeps_on_provider", using: :btree
  add_index "sleeps", ["user_id"], name: "index_sleeps_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                default: "",    null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "password_digest",      default: "",    null: false
    t.boolean  "admin",                default: false, null: false
    t.boolean  "guest",                default: false, null: false
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
    t.string   "education"
    t.string   "referred_by"
    t.hstore   "stats"
    t.string   "ios_device_token"
    t.string   "android_device_token"
    t.boolean  "is_dob_by_age",        default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["referred_by"], name: "index_users_on_referred_by", using: :btree

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
