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

ActiveRecord::Schema.define(:version => 20130313230912) do

  create_table "adjective_circles", :force => true do |t|
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
    t.datetime "created_at",      :null => false
    t.datetime "updated_at",      :null => false
  end

  create_table "assessments", :force => true do |t|
    t.date     "date_taken"
    t.string   "score"
    t.integer  "definition_id"
    t.integer  "user_id"
    t.text     "event_log"
    t.text     "intermediate_results"
    t.text     "stages"
    t.boolean  "results_ready"
    t.integer  "profile_description_id"
    t.text     "aggregate_results"
    t.string   "big5_dimension"
    t.string   "holland6_dimension"
    t.string   "emo8_dimension"
    t.integer  "stage_completed"
    t.datetime "created_at",             :null => false
    t.datetime "updated_at",             :null => false
    t.string   "status"
  end

  create_table "definitions", :force => true do |t|
    t.string   "name"
    t.text     "stages"
    t.text     "instructions"
    t.text     "end_remarks"
    t.string   "experiment"
    t.string   "icon"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  create_table "elements", :force => true do |t|
    t.string   "name"
    t.string   "version"
    t.float    "standard_deviation"
    t.float    "mean"
    t.float    "weight_extraversion"
    t.float    "weight_conscientiousness"
    t.float    "weight_neuroticism"
    t.float    "weight_openness"
    t.float    "weight_agreeableness"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  create_table "images", :force => true do |t|
    t.string   "name"
    t.text     "elements"
    t.string   "primary_color"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "oauth_access_grants", :force => true do |t|
    t.integer  "resource_owner_id", :null => false
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.integer  "expires_in",        :null => false
    t.string   "redirect_uri",      :null => false
    t.datetime "created_at",        :null => false
    t.datetime "revoked_at"
    t.string   "scopes"
  end

  add_index "oauth_access_grants", ["token"], :name => "index_oauth_access_grants_on_token", :unique => true

  create_table "oauth_access_tokens", :force => true do |t|
    t.integer  "resource_owner_id"
    t.integer  "application_id",    :null => false
    t.string   "token",             :null => false
    t.string   "refresh_token"
    t.integer  "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at",        :null => false
    t.string   "scopes"
  end

  add_index "oauth_access_tokens", ["refresh_token"], :name => "index_oauth_access_tokens_on_refresh_token", :unique => true
  add_index "oauth_access_tokens", ["resource_owner_id"], :name => "index_oauth_access_tokens_on_resource_owner_id"
  add_index "oauth_access_tokens", ["token"], :name => "index_oauth_access_tokens_on_token", :unique => true

  create_table "oauth_applications", :force => true do |t|
    t.string   "name",         :null => false
    t.string   "uid",          :null => false
    t.string   "secret",       :null => false
    t.string   "redirect_uri", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "oauth_applications", ["uid"], :name => "index_oauth_applications_on_uid", :unique => true

  create_table "profile_descriptions", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "one_liner"
    t.text     "bullet_description"
    t.string   "big5_dimension"
    t.string   "holland6_dimension"
    t.string   "code"
    t.string   "logo_url"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
