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

ActiveRecord::Schema.define(version: 2016_05_09_213929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "contacts", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.text "text", null: false
    t.string "title", null: false
    t.datetime "reported_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reported_at"], name: "index_contacts_on_reported_at"
    t.index ["user_id"], name: "index_contacts_on_user_id"
  end

  create_table "courses", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_courses_on_name", unique: true
    t.index ["published"], name: "index_courses_on_published"
  end

  create_table "project_bundles", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "file_name"
    t.boolean "teams_only", default: false, null: false
    t.bigint "size_bytes", default: 0, null: false
    t.index ["project_id"], name: "index_project_bundles_on_project_id"
    t.index ["user_id"], name: "index_project_bundles_on_user_id"
  end

  create_table "projects", id: :serial, force: :cascade do |t|
    t.datetime "due_date", null: false
    t.datetime "start_date", null: false
    t.string "name", null: false
    t.integer "course_id"
    t.boolean "quiz", default: false, null: false
    t.boolean "published", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "reruning_submissions", default: false, null: false
    t.index ["course_id"], name: "index_projects_on_course_id"
    t.index ["due_date"], name: "index_projects_on_due_date"
    t.index ["name"], name: "index_projects_on_name"
    t.index ["published"], name: "index_projects_on_published"
    t.index ["quiz"], name: "index_projects_on_quiz"
    t.index ["start_date"], name: "index_projects_on_start_date"
  end

  create_table "reset_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_reset_tokens_on_created_at"
    t.index ["user_id", "token"], name: "index_reset_tokens_on_user_id_and_token"
    t.index ["user_id"], name: "index_reset_tokens_on_user_id", unique: true
  end

  create_table "results", id: :serial, force: :cascade do |t|
    t.integer "submission_id"
    t.integer "test_suite_id"
    t.integer "project_id"
    t.boolean "compiled", null: false
    t.text "compiler_stderr", null: false
    t.text "compiler_stdout", null: false
    t.integer "grade", null: false
    t.integer "max_grade", null: false
    t.boolean "hidden", null: false
    t.boolean "success", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_results_on_project_id"
    t.index ["submission_id"], name: "index_results_on_submission_id"
    t.index ["test_suite_id"], name: "index_results_on_test_suite_id"
  end

  create_table "solutions", id: :serial, force: :cascade do |t|
    t.integer "submission_id"
    t.binary "code", null: false
    t.string "file_name", null: false
    t.string "mime_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["submission_id"], name: "index_solutions_on_submission_id"
  end

  create_table "studentships", id: :serial, force: :cascade do |t|
    t.integer "course_id"
    t.integer "student_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_studentships_on_course_id"
    t.index ["student_id"], name: "index_studentships_on_student_id"
  end

  create_table "submissions", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.integer "submitter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "team"
    t.index ["created_at"], name: "index_submissions_on_created_at"
    t.index ["project_id", "team"], name: "index_submissions_on_project_id_and_team"
    t.index ["project_id"], name: "index_submissions_on_project_id"
    t.index ["submitter_id"], name: "index_submissions_on_submitter_id"
  end

  create_table "suite_cases", id: :serial, force: :cascade do |t|
    t.integer "test_suite_id"
    t.string "name", null: false
    t.integer "grade", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_suite_cases_on_name"
    t.index ["test_suite_id"], name: "index_suite_cases_on_test_suite_id"
  end

  create_table "suite_codes", id: :serial, force: :cascade do |t|
    t.integer "test_suite_id"
    t.binary "code", null: false
    t.string "file_name", null: false
    t.string "mime_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["test_suite_id"], name: "index_suite_codes_on_test_suite_id"
  end

  create_table "team_jobs", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.binary "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_team_jobs_on_user_id"
  end

  create_table "test_cases", id: :serial, force: :cascade do |t|
    t.integer "result_id"
    t.string "name", null: false
    t.text "detail"
    t.text "java_klass_name"
    t.boolean "passed", null: false
    t.integer "grade", null: false
    t.integer "max_grade", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["result_id"], name: "index_test_cases_on_result_id"
  end

  create_table "test_suites", id: :serial, force: :cascade do |t|
    t.integer "project_id"
    t.boolean "hidden", default: true, null: false
    t.boolean "ready", default: false, null: false
    t.integer "max_grade", default: 0, null: false
    t.integer "timeout", default: 60, null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hidden"], name: "index_test_suites_on_hidden"
    t.index ["project_id"], name: "index_test_suites_on_project_id"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", null: false
    t.string "password_digest", null: false
    t.string "email", null: false
    t.boolean "student", null: false
    t.boolean "verified", default: false, null: false
    t.string "major"
    t.string "team"
    t.integer "guc_suffix"
    t.integer "guc_prefix"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "super_user", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["guc_prefix"], name: "index_users_on_guc_prefix"
    t.index ["guc_suffix"], name: "index_users_on_guc_suffix"
    t.index ["name"], name: "index_users_on_name"
    t.index ["student"], name: "index_users_on_student"
    t.index ["super_user"], name: "index_users_on_super_user"
    t.index ["team"], name: "index_users_on_team"
  end

  create_table "verification_tokens", id: :serial, force: :cascade do |t|
    t.integer "user_id"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_verification_tokens_on_created_at"
    t.index ["user_id", "token"], name: "index_verification_tokens_on_user_id_and_token"
    t.index ["user_id"], name: "index_verification_tokens_on_user_id", unique: true
  end

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
