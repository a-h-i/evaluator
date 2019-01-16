require 'rails_helper'

RSpec.describe Api::SubmissionsController, type: :controller do
  context 'create' do
    let(:student) { FactoryGirl.create(:student) }
    let(:teacher) { FactoryGirl.create(:teacher) }
    let(:unpublished_course) { FactoryGirl.create(:course) }
    let(:published_course) { FactoryGirl.create(:course, published: true) }
    let(:published_project_published_course) { FactoryGirl.create(:project, course: published_course, published: true) }
    let(:unpublished_project_published_course) { FactoryGirl.create(:project, course: published_course, published: false) }
    let(:published_project_unpublished_course) { FactoryGirl.create(:project, course: unpublished_course, published: true) }
    let(:unpublished_project_unpublished_course) { FactoryGirl.create(:project, course: unpublished_course, published: false) }
    before :each do
      @file = fixture_file_upload('/files/submissions/csv_submission.zip', 'application/zip', true)
    end
    it 'does not allow unauthorized' do
      expect do
        post :create, project_id: published_project_published_course.id, file: @file
      end.to change(Submission, :count).by(0).and change(Solution, :count).by(0)
      expect(response).to be_unauthorized
    end
    it 'allows student' do
      expect do
        set_token student.token
        post :create, project_id: published_project_published_course.id, file: @file
      end.to change(Submission, :count).by(1).and change(Solution, :count).by(1)
      expect(response).to be_created
      expect(Submission.first.submitter.id).to eql student.id
    end
    it 'allows teacher' do
      expect do
        set_token teacher.token
        post :create, project_id: published_project_published_course.id, file: @file
      end.to change(Submission, :count).by(1).and change(Solution, :count).by(1)
      expect(response).to be_created
      expect(Submission.first.submitter.id).to eql teacher.id
    end
    it 'requires a file' do
      expect do
        set_token student.token
        post :create, project_id: published_project_published_course.id
      end.to change(Submission, :count).by(0).and change(Solution, :count).by(0)
      expect(response).to be_bad_request
    end
    it 'can not submit to an unpublished project of a published course' do
      expect do
        set_token student.token
        post :create, project_id: unpublished_project_published_course.id, file: @file
      end.to change(Submission, :count).by(0).and change(Solution, :count).by(0)
      expect(response).to be_unprocessable
    end

    it 'can not submit to a published project of an unpublished course' do
      expect do
        set_token student.token
        post :create, project_id: published_project_unpublished_course.id, file: @file
      end.to change(Submission, :count).by(0).and change(Solution, :count).by(0)
      expect(response).to be_unprocessable
    end

    it 'can not submit to an unpublished project of an unpublished course' do
      expect do
        set_token student.token
        post :create, project_id: unpublished_project_unpublished_course.id, file: @file
      end.to change(Submission, :count).by(0).and change(Solution, :count).by(0)
      expect(response).to be_unprocessable
    end

    it 'queues submission evaluation job' do
      expect(SubmissionEvaluationJob).to receive(:perform_later).once
      set_token student.token
      post :create, project_id: published_project_published_course.id, file: @file
    end
  end

  context 'rerun' do
    before :each do
      @submission = FactoryGirl.create(:submission)
      @solution = FactoryGirl.build(:solution)
      @solution.submission = @submission
      @solution.save!
      @submission.solution = @solution
      @submission.save!
    end
    let(:teacher) { FactoryGirl.create(:teacher) }
    it 'queues evaluation job' do
      expect(SubmissionEvaluationJob).to receive(:perform_later).once
      set_token teacher.token
      get :rerun, id: @submission.id
      expect(response).to be_success
    end
    it 'does not allow unauthorized' do
      expect(SubmissionEvaluationJob).to_not receive(:perform_later)
      get :rerun, id: @submission.id
      expect(response).to be_unauthorized
    end
    it 'does not allow student' do
      expect(SubmissionEvaluationJob).to_not receive(:perform_later)
      set_token @submission.submitter.token
      get :rerun, id: @submission.id
      expect(response).to be_forbidden
    end
  end

  context 'download' do
    before :each do
      @submission = FactoryGirl.create(:submission)
      @solution = FactoryGirl.build(:solution)
      @solution.submission = @submission
      @solution.save!
      @submission.solution = @solution
      @submission.save!
    end

    it 'does not allow unauthorized' do
      get :download, id: @submission.id
      expect(response).to be_unauthorized
    end

    it 'allows submitter to download' do
      set_token @submission.submitter.token
      get :download, id: @submission.id
      expect(response).to be_success
    end

    it 'allows a teacher to download' do
      set_token FactoryGirl.create(:teacher).token
      get :download, id: @submission.id
      expect(response).to be_success
    end
    it 'does not allow an unverified user' do
      set_token FactoryGirl.create(:teacher, verified: false).token
      get :download, id: @submission.id
      expect(response).to be_forbidden
    end
    it 'does not allow an unrelated student to download' do
      set_token FactoryGirl.create(:student).token
      get :download, id: @submission.id
      expect(response).to be_forbidden
    end
    it 'does not allow student of same team to download' do
      set_token FactoryGirl.create(:student, team: @submission.submitter.team).token
      get :download, id: @submission.id
      expect(response).to be_forbidden
    end
  end

  context 'show' do
    before :each do
      @submission = FactoryGirl.create(:submission)
      @solution = FactoryGirl.build(:solution)
      @solution.submission = @submission
      @solution.save!
      @submission.solution = @solution
      @submission.save!
    end

    it 'does not allow unauthorized' do
      get :show, id: @submission.id
      expect(response).to be_unauthorized
    end

    it 'allows submitter to download' do
      set_token @submission.submitter.token
      get :show, id: @submission.id
      expect(response).to be_success
      expect(json_response).to include(
        :id, :submitter_id, :project_id, :created_at, :updated_at
      )
    end

    it 'does not allow student of same team show' do
      set_token FactoryGirl.create(:student, team: @submission.submitter.team).token
      get :show, id: @submission.id
      expect(response).to be_forbidden
    end

    it 'allows a teacher to download' do
      set_token FactoryGirl.create(:teacher).token
      get :show, id: @submission.id
      expect(response).to be_success
    end
    it 'does not allow an unverified user' do
      set_token FactoryGirl.create(:teacher, verified: false).token
      get :show, id: @submission.id
      expect(response).to be_forbidden
    end
    it 'does not allow an unrelated student to download' do
      set_token FactoryGirl.create(:student).token
      get :show, id: @submission.id
      expect(response).to be_forbidden
    end
  end

  context 'index' do
    before :each do
      @create_submission = lambda do |project, submitter = nil|
        project ||= FactoryGirl.create(:project)
        submitter ||= FactoryGirl.create(:student)
        submission = FactoryGirl.create(:submission, project: project, submitter: submitter)
        solution = FactoryGirl.build(:solution)
        solution.submission = submission
        solution.save!
        submission.solution = solution
        submission.save!
      end
      @default_project = FactoryGirl.create(:project, published: true, course: FactoryGirl.create(:course, published: true))
      5.times { @create_submission.call @default_project }
    end
    it 'does not allow unauthorized' do
      get :index, project_id: @default_project.id
      expect(response).to be_unauthorized
    end
    it 'allows teacher' do
      teacher = FactoryGirl.create(:teacher)
      set_token teacher.token
      get :index, project_id: @default_project.id
      expect(response).to be_success
      expect(json_response[:submissions].size).to_not eql 0
    end
    it 'allows a student' do
      student = User.students.first
      set_token student.token
      get :index, project_id: @default_project.id
      expect(response).to be_success
    end
    it 'has pagination' do
      student = User.students.first
      set_token student.token
      get :index, project_id: @default_project.id
      expect(response).to be_success
      expect(json_response).to include(
        :submissions, :page, :page_size, :total_pages
      )
    end
    it 'Student cant see other students submission' do
      student = FactoryGirl.create(:student, verified: true)
      set_token student.token
      get :index, project_id: @default_project.id
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 0
    end

    it 'student cant query by team' do
      team = Submission.first.submitter.team
      student = FactoryGirl.create(:student, verified: true)
      set_token student.token
      get :index, project_id: @default_project.id
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 0
    end

    it 'students can not see own team submissions' do
      team = Submission.first.submitter.team
      student = FactoryGirl.create(:student, verified: true)
      set_token student.token
      get :index, project_id: @default_project.id, submitter: { team: team }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 0
    end

    it 'student can see own submissions' do
      student = FactoryGirl.create(:student, verified: true)
      3.times { @create_submission.call @default_project, student }
      set_token student.token
      get :index, project_id: @default_project.id
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 3
    end


    it 'teacher can query by name' do
      teacher = FactoryGirl.create(:teacher, verified: true)
      student = FactoryGirl.create(:student, verified: true)
      student_two = FactoryGirl.create(:student, verified: true, name: student.name)
      4.times { @create_submission.call @default_project, student }
      1.times { @create_submission.call @default_project, student_two }
      set_token teacher.token
      get :index, project_id: @default_project.id, submitter: { name: student.name }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 5
      correct_ids = json_response[:submissions].reduce(true) do |memo, item|
        memo &&  [student.id, student_two.id].include?(item[:submitter_id])
      end
      expect(correct_ids).to be true
    end

    it 'teacher can query by team name' do
      teacher = FactoryGirl.create(:teacher, verified: true)
      student = FactoryGirl.create(:student, verified: true, team: 'Dat gap')
      student_two = FactoryGirl.create(:student, verified: true, team: student.team)
      1.times { @create_submission.call @default_project, student }
      1.times { @create_submission.call @default_project, student_two }
      set_token teacher.token
      get :index, project_id: @default_project.id, submitter: { team: student.team }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 2
      correct_ids = json_response[:submissions].reduce(true) do |memo, item|
        memo &&  [student.id, student_two.id].include?(item[:submitter_id])
      end
      expect(correct_ids).to be true
    end
    it 'teacher can query by team email' do
      teacher = FactoryGirl.create(:teacher, verified: true)
      student = FactoryGirl.create(:student, verified: true)
      3.times { @create_submission.call @default_project, student }
      set_token teacher.token
      get :index, project_id: @default_project.id, submitter: { email: student.email }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 3
      correct_ids = json_response[:submissions].reduce(true) do |memo, item|
        memo &&  item[:submitter_id] == student.id
      end
      expect(correct_ids).to be true
    end
  end
end
