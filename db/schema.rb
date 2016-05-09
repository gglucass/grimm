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

ActiveRecord::Schema.define(version: 20160509115053) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "boards", force: :cascade do |t|
    t.integer  "project_id"
    t.string   "name"
    t.string   "external_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "boards", ["project_id"], name: "index_boards_on_project_id", unique: true, using: :btree

  create_table "comments", force: :cascade do |t|
    t.string   "external_id"
    t.text     "text"
    t.integer  "defect_id"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "comments", ["defect_id"], name: "index_comments_on_defect_id", using: :btree
  add_index "comments", ["user_id"], name: "index_comments_on_user_id", using: :btree

  create_table "defects", force: :cascade do |t|
    t.text     "highlight"
    t.string   "kind"
    t.string   "subkind"
    t.string   "severity"
    t.boolean  "false_positive"
    t.integer  "project_id"
    t.integer  "story_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "defects", ["project_id"], name: "index_defects_on_project_id", using: :btree
  add_index "defects", ["story_id"], name: "index_defects_on_story_id", using: :btree

  create_table "integrations", force: :cascade do |t|
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "kind"
    t.text     "auth_info"
    t.integer  "user_id"
    t.string   "site_url"
    t.string   "jira_visibility"
  end

  add_index "integrations", ["user_id"], name: "index_integrations_on_user_id", using: :btree

  create_table "integrations_projects", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "integration_id"
  end

  add_index "integrations_projects", ["integration_id"], name: "index_integrations_projects_on_integration_id", using: :btree
  add_index "integrations_projects", ["project_id", "integration_id"], name: "index_integrations_projects_on_project_id_and_integration_id", unique: true, using: :btree
  add_index "integrations_projects", ["project_id"], name: "index_integrations_projects_on_project_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name"
    t.string   "external_id"
    t.datetime "created_at",                                                                null: false
    t.datetime "updated_at",                                                                null: false
    t.text     "format",                             default: "As a, I'm able to, So that"
    t.string   "kind"
    t.boolean  "create_comments",                    default: false
    t.boolean  "publik",                             default: false
    t.string   "requirements_document_file_name"
    t.string   "requirements_document_content_type"
    t.integer  "requirements_document_file_size"
    t.datetime "requirements_document_updated_at"
    t.string   "site_url"
    t.string   "custom_issue_type"
  end

  create_table "projects_users", id: false, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
  end

  add_index "projects_users", ["project_id"], name: "index_projects_users_on_project_id", using: :btree
  add_index "projects_users", ["user_id"], name: "index_projects_users_on_user_id", using: :btree

  create_table "sprints", force: :cascade do |t|
    t.integer  "board_id"
    t.string   "name"
    t.string   "external_id"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.float    "recidivism_rate"
    t.datetime "start_date"
    t.datetime "end_date"
  end

  add_index "sprints", ["board_id"], name: "index_sprints_on_board_id", unique: true, using: :btree

  create_table "stories", force: :cascade do |t|
    t.text     "title"
    t.string   "external_id"
    t.integer  "project_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.text     "role"
    t.text     "means"
    t.text     "ends"
    t.text     "priority"
    t.text     "status"
    t.text     "comments"
    t.text     "description"
    t.string   "estimation"
    t.string   "external_key"
  end

  add_index "stories", ["project_id"], name: "index_stories_on_project_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.integer  "integration_id"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["integration_id"], name: "index_users_on_integration_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",  null: false
    t.integer  "item_id",    null: false
    t.string   "event",      null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

  create_table "webhooks", force: :cascade do |t|
    t.text     "json_string"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.string   "site_url"
  end

  add_foreign_key "comments", "defects"
  add_foreign_key "comments", "users"
  add_foreign_key "defects", "projects"
  add_foreign_key "defects", "stories"
  add_foreign_key "stories", "projects"
end
