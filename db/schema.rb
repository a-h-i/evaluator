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

ActiveRecord::Schema.define(version: 20160509213929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_trgm"

  create_table "contacts", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "text",        null: false
    t.string   "title",       null: false
    t.datetime "reported_at", null: false
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "contacts", ["reported_at"], name: "index_contacts_on_reported_at", using: :btree
  add_index "contacts", ["user_id"], name: "index_contacts_on_user_id", using: :btree

  create_table "courses", force: :cascade do |t|
    t.string   "name",                        null: false
    t.text     "description",                 null: false
    t.boolean  "published",   default: false, null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "courses", ["name"], name: "index_courses_on_name", unique: true, using: :btree
  add_index "courses", ["published"], name: "index_courses_on_published", using: :btree

  create_table "project_bundles", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "user_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.string   "file_name"
    t.boolean  "teams_only",           default: false, null: false
    t.integer  "size_bytes", limit: 8, default: 0,     null: false
  end

  add_index "project_bundles", ["project_id"], name: "index_project_bundles_on_project_id", using: :btree
  add_index "project_bundles", ["user_id"], name: "index_project_bundles_on_user_id", using: :btree

  create_table "projects", force: :cascade do |t|
    t.datetime "due_date",                             null: false
    t.datetime "start_date",                           null: false
    t.string   "name",                                 null: false
    t.integer  "course_id"
    t.boolean  "quiz",                 default: false, null: false
    t.boolean  "published",            default: false, null: false
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "reruning_submissions", default: false, null: false
  end

  add_index "projects", ["course_id"], name: "index_projects_on_course_id", using: :btree
  add_index "projects", ["due_date"], name: "index_projects_on_due_date", using: :btree
  add_index "projects", ["name"], name: "index_projects_on_name", using: :btree
  add_index "projects", ["published"], name: "index_projects_on_published", using: :btree
  add_index "projects", ["quiz"], name: "index_projects_on_quiz", using: :btree
  add_index "projects", ["start_date"], name: "index_projects_on_start_date", using: :btree

  create_table "reset_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "reset_tokens", ["created_at"], name: "index_reset_tokens_on_created_at", using: :btree
  add_index "reset_tokens", ["user_id", "token"], name: "index_reset_tokens_on_user_id_and_token", using: :btree
  add_index "reset_tokens", ["user_id"], name: "index_reset_tokens_on_user_id", unique: true, using: :btree

  create_table "results", force: :cascade do |t|
    t.integer  "submission_id"
    t.integer  "test_suite_id"
    t.integer  "project_id"
    t.boolean  "compiled",        null: false
    t.text     "compiler_stderr", null: false
    t.text     "compiler_stdout", null: false
    t.integer  "grade",           null: false
    t.integer  "max_grade",       null: false
    t.boolean  "hidden",          null: false
    t.boolean  "success",         null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "results", ["project_id"], name: "index_results_on_project_id", using: :btree
  add_index "results", ["submission_id"], name: "index_results_on_submission_id", using: :btree
  add_index "results", ["test_suite_id"], name: "index_results_on_test_suite_id", using: :btree

  create_table "solutions", force: :cascade do |t|
    t.integer  "submission_id"
    t.binary   "code",          null: false
    t.string   "file_name",     null: false
    t.string   "mime_type",     null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "solutions", ["submission_id"], name: "index_solutions_on_submission_id", using: :btree

  create_table "studentships", force: :cascade do |t|
    t.integer  "course_id"
    t.integer  "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "studentships", ["course_id"], name: "index_studentships_on_course_id", using: :btree
  add_index "studentships", ["student_id"], name: "index_studentships_on_student_id", using: :btree

  create_table "submissions", force: :cascade do |t|
    t.integer  "project_id"
    t.integer  "submitter_id", null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "team"
  end

  add_index "submissions", ["created_at"], name: "index_submissions_on_created_at", using: :btree
  add_index "submissions", ["project_id", "team"], name: "index_submissions_on_project_id_and_team", using: :btree
  add_index "submissions", ["project_id"], name: "index_submissions_on_project_id", using: :btree
  add_index "submissions", ["submitter_id"], name: "index_submissions_on_submitter_id", using: :btree

  create_table "suite_cases", force: :cascade do |t|
    t.integer  "test_suite_id"
    t.string   "name",                      null: false
    t.integer  "grade",         default: 0, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "suite_cases", ["name"], name: "index_suite_cases_on_name", using: :btree
  add_index "suite_cases", ["test_suite_id"], name: "index_suite_cases_on_test_suite_id", using: :btree

  create_table "suite_codes", force: :cascade do |t|
    t.integer  "test_suite_id"
    t.binary   "code",          null: false
    t.string   "file_name",     null: false
    t.string   "mime_type",     null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  add_index "suite_codes", ["test_suite_id"], name: "index_suite_codes_on_test_suite_id", using: :btree

  create_table "team_jobs", force: :cascade do |t|
    t.integer  "user_id"
    t.binary   "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "team_jobs", ["user_id"], name: "index_team_jobs_on_user_id", using: :btree

  create_table "test_cases", force: :cascade do |t|
    t.integer  "result_id"
    t.string   "name",            null: false
    t.text     "detail"
    t.text     "java_klass_name"
    t.boolean  "passed",          null: false
    t.integer  "grade",           null: false
    t.integer  "max_grade",       null: false
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  add_index "test_cases", ["result_id"], name: "index_test_cases_on_result_id", using: :btree

  create_table "test_suites", force: :cascade do |t|
    t.integer  "project_id"
    t.boolean  "hidden",     default: true,  null: false
    t.boolean  "ready",      default: false, null: false
    t.integer  "max_grade",  default: 0,     null: false
    t.integer  "timeout",    default: 60,    null: false
    t.string   "name",                       null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "test_suites", ["hidden"], name: "index_test_suites_on_hidden", using: :btree
  add_index "test_suites", ["project_id"], name: "index_test_suites_on_project_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                            null: false
    t.string   "password_digest",                 null: false
    t.string   "email",                           null: false
    t.boolean  "student",                         null: false
    t.boolean  "verified",        default: false, null: false
    t.string   "major"
    t.string   "team"
    t.integer  "guc_suffix"
    t.integer  "guc_prefix"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.boolean  "super_user",      default: false, null: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["guc_prefix"], name: "index_users_on_guc_prefix", using: :btree
  add_index "users", ["guc_suffix"], name: "index_users_on_guc_suffix", using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["student"], name: "index_users_on_student", using: :btree
  add_index "users", ["super_user"], name: "index_users_on_super_user", using: :btree
  add_index "users", ["team"], name: "index_users_on_team", using: :btree

  create_table "verification_tokens", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "token",      null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "verification_tokens", ["created_at"], name: "index_verification_tokens_on_created_at", using: :btree
  add_index "verification_tokens", ["user_id", "token"], name: "index_verification_tokens_on_user_id_and_token", using: :btree
  add_index "verification_tokens", ["user_id"], name: "index_verification_tokens_on_user_id", unique: true, using: :btree

  add_foreign_key "contacts", "users", on_delete: :nullify
  add_foreign_key "project_bundles", "projects", on_delete: :cascade
  add_foreign_key "project_bundles", "users", on_delete: :cascade
  add_foreign_key "projects", "courses", on_delete: :cascade
  add_foreign_key "reset_tokens", "users", on_delete: :cascade
  add_foreign_key "results", "projects", on_delete: :cascade
  add_foreign_key "results", "submissions", on_delete: :cascade
  add_foreign_key "results", "test_suites", on_delete: :cascade
  add_foreign_key "solutions", "submissions", on_delete: :cascade
  add_foreign_key "studentships", "courses", on_delete: :cascade
  add_foreign_key "studentships", "users", column: "student_id", on_delete: :cascade
  add_foreign_key "submissions", "projects", on_delete: :cascade
  add_foreign_key "submissions", "users", column: "submitter_id", on_delete: :cascade
  add_foreign_key "suite_cases", "test_suites", on_delete: :cascade
  add_foreign_key "suite_codes", "test_suites", on_delete: :cascade
  add_foreign_key "team_jobs", "users", on_delete: :cascade
  add_foreign_key "test_cases", "results", on_delete: :cascade
  add_foreign_key "test_suites", "projects", on_delete: :cascade
  add_foreign_key "verification_tokens", "users", on_delete: :cascade
end
