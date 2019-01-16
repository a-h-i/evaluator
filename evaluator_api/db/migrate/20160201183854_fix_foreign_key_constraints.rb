class FixForeignKeyConstraints < ActiveRecord::Migration[4.2]
  def change
    remove_foreign_key 'projects', 'courses'
    add_foreign_key 'projects', 'courses', on_delete: :cascade
    remove_foreign_key 'reset_tokens', 'users'
    add_foreign_key 'reset_tokens', 'users', on_delete: :cascade
    remove_foreign_key 'results', 'projects'
    add_foreign_key 'results', 'projects', on_delete: :cascade
    remove_foreign_key 'results', 'submissions'
    add_foreign_key 'results', 'submissions', on_delete: :cascade
    remove_foreign_key 'results', 'test_suites'
    add_foreign_key 'results', 'test_suites', on_delete: :cascade
    remove_foreign_key 'solutions', 'submissions'
    add_foreign_key 'solutions', 'submissions', on_delete: :cascade
    remove_foreign_key 'studentships', 'courses'
    add_foreign_key 'studentships', 'courses', on_delete: :cascade
    remove_foreign_key 'studentships', column: 'student_id'
    add_foreign_key 'studentships', 'users', column: 'student_id', on_delete: :cascade
    remove_foreign_key 'submissions', 'projects'
    add_foreign_key 'submissions', 'projects', on_delete: :cascade
    remove_foreign_key 'submissions', column: 'submitter_id'
    add_foreign_key 'submissions', 'users', column: 'submitter_id', on_delete: :cascade
    remove_foreign_key 'suite_cases', 'test_suites'
    add_foreign_key 'suite_cases', 'test_suites', on_delete: :cascade
    remove_foreign_key 'team_grades', 'projects'
    add_foreign_key 'team_grades', 'projects', on_delete: :cascade
    remove_foreign_key 'team_grades', 'results'
    add_foreign_key 'team_grades', 'results', on_delete: :cascade
    remove_foreign_key 'test_cases', 'results'
    add_foreign_key 'test_cases', 'results', on_delete: :cascade
    remove_foreign_key 'test_suites', 'projects'
    add_foreign_key 'test_suites', 'projects', on_delete: :cascade
    remove_foreign_key 'verification_tokens', 'users'
    add_foreign_key 'verification_tokens', 'users', on_delete: :cascade
  end
end
