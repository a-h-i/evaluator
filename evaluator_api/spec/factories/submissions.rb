# == Schema Information
#
# Table name: submissions
#
#  id           :bigint(8)        not null, primary key
#  project_id   :bigint(8)        not null
#  submitter_id :bigint(8)        not null
#  course_id    :bigint(8)        not null
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  mime_type    :text             not null
#  file_name    :text             not null
#  team         :text
#
# Indexes
#
#  index_submissions_on_submitter_id_and_project_id_and_created_at  (submitter_id,project_id,created_at)
#

FactoryBot.define do
  factory :submission do
    project do
      FactoryBot.create(:project, published: true,
                                  course: FactoryBot.create(:course, published: true))
    end
    submitter { FactoryBot.create(:student, verified: true) }
    file do
      path = File.join(Rails.root.join("spec/fixtures/files"),
                       "submissions/csv_submission.zip")
      File.open(path, "rb")
    end

    factory :submission_with_registration do
      after(:create) do |submission|
        FactoryBot.create(:student_course_registration, course: submission.course, student: submission.submitter)
      end
    end
    factory :team_submission do
      after(:create) do |submission|
        if StudentCourseRegistration.exists?(student: submission.submitter, course: submission.course)
          submission.team = StudentCourseRegistration.where(student: submission.submitter, course: submission.course).first.team
          submission.save
        else
          submission.team = FactoryBot.create(:student_course_registration, course: submission.course, student: submission.submitter, team: Faker::Lorem.word).team
          submission.save
        end
      end
    end
  end
end
