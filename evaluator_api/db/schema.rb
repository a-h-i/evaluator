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

ActiveRecord::Schema.define(version: 2019_02_20_213652) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  create_table "courses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "name", null: false
    t.text "description", null: false
    t.boolean "published", default: false, null: false
    t.index ["name"], name: "courses_name_key", unique: true
  end

  create_table "projects", force: :cascade do |t|
    t.bigserial "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "due_date", null: false
    t.datetime "start_date", null: false
    t.text "name", null: false
    t.boolean "published", default: false, null: false
    t.boolean "quiz", default: false, null: false
    t.boolean "reruning_submissions", default: false, null: false
    t.index ["course_id", "name"], name: "projects_course_id_name_key", unique: true
  end

  create_table "student_course_registrations", force: :cascade do |t|
    t.bigserial "course_id", null: false
    t.bigserial "student_id", null: false
    t.text "team"
    t.index ["course_id", "student_id"], name: "student_course_registrations_course_id_student_id_key", unique: true
  end

  create_table "submissions", force: :cascade do |t|
    t.bigserial "project_id", null: false
    t.bigserial "submitter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "team"
  end

  create_table "test_suites", force: :cascade do |t|
    t.bigserial "project_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "timeout", default: 60, null: false
    t.integer "max_grade", default: 0, null: false
    t.text "name", null: false
    t.jsonb "test_cases"
    t.boolean "hidden", default: true, null: false
    t.boolean "ready", default: false, null: false
    t.index ["project_id", "name"], name: "test_suites_project_id_name_key", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "guc_prefix"
    t.integer "guc_suffix"
    t.text "password_digest", null: false
    t.text "name", null: false
    t.text "email", null: false
    t.text "major"
    t.text "study_group"
    t.boolean "verified", default: false, null: false
    t.boolean "verified_teacher", default: false, null: false
    t.boolean "super_user", default: false, null: false
    t.boolean "student", default: true, null: false
    t.index ["email"], name: "users_email_key", unique: true
  end

  add_foreign_key "projects", "courses", name: "projects_course_id_fkey"
  add_foreign_key "student_course_registrations", "courses", name: "student_course_registrations_course_id_fkey", on_delete: :cascade
  add_foreign_key "student_course_registrations", "users", column: "student_id", name: "student_course_registrations_student_id_fkey", on_delete: :cascade
  add_foreign_key "submissions", "projects", name: "submissions_project_id_fkey"
  add_foreign_key "submissions", "users", column: "submitter_id", name: "submissions_submitter_id_fkey"
  add_foreign_key "test_suites", "projects", name: "test_suites_project_id_fkey"
end