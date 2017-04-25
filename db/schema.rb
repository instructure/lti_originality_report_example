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

ActiveRecord::Schema.define(version: 20170421204533) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "assignments", force: :cascade do |t|
    t.string   "lti_assignment_id", null: false
    t.integer  "tool_proxy_id",     null: false
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.hstore   "settings"
    t.integer  "tc_id"
    t.index ["lti_assignment_id"], name: "index_assignments_on_lti_assignment_id", using: :btree
    t.index ["tc_id"], name: "index_assignments_on_tc_id", using: :btree
    t.index ["tool_proxy_id"], name: "index_assignments_on_tool_proxy_id", using: :btree
  end

  create_table "originality_reports", force: :cascade do |t|
    t.bigint   "tc_id",                      null: false
    t.integer  "file_id",                    null: false
    t.float    "originality_score"
    t.integer  "submission_id",              null: false
    t.integer  "originality_report_file_id"
    t.string   "originality_report_url"
    t.string   "originality_report_lti_url"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["submission_id"], name: "index_originality_reports_on_submission_id", using: :btree
    t.index ["tc_id"], name: "index_originality_reports_on_tc_id", using: :btree
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint   "tc_id",         null: false
    t.integer  "assignment_id", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.text     "attachments"
    t.index ["assignment_id"], name: "index_submissions_on_assignment_id", using: :btree
    t.index ["tc_id"], name: "index_submissions_on_tc_id", using: :btree
  end

  create_table "tool_proxies", force: :cascade do |t|
    t.string "guid",               null: false
    t.string "shared_secret",      null: false
    t.string "tcp_url",            null: false
    t.string "base_url",           null: false
    t.string "authorization_url"
    t.string "report_service_url"
    t.index ["guid"], name: "index_tool_proxies_on_guid", using: :btree
  end

  add_foreign_key "assignments", "tool_proxies"
  add_foreign_key "originality_reports", "submissions"
  add_foreign_key "submissions", "assignments"
end
