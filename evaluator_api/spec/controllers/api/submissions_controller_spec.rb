require "rails_helper"

RSpec.describe Api::SubmissionsController, type: :controller do
  context "create" do
    let(:student) { FactoryBot.create(:student) }
    let(:teacher) { FactoryBot.create(:teacher) }
    let(:unpublished_course) { FactoryBot.create(:course) }
    let(:published_course) { FactoryBot.create(:course, published: true) }
    let(:published_project_published_course) { FactoryBot.create(:project, course: published_course, published: true) }
    let(:unpublished_project_published_course) { FactoryBot.create(:project, course: published_course, published: false) }
    let(:published_project_unpublished_course) { FactoryBot.create(:project, course: unpublished_course, published: true) }
    let(:unpublished_project_unpublished_course) { FactoryBot.create(:project, course: unpublished_course, published: false) }
    before :each do
      @file = fixture_file_upload("/files/submissions/csv_submission.zip", "application/zip", true)
    end
    it "does not allow unauthorized" do
      expect do
        post :create, params: {project_id: published_project_published_course.id, file: @file}
      end.to change(Submission, :count).by(0)
      expect(response).to be_unauthorized
    end
    it "allows student" do

      expect do 
        allow(MessagingService).to receive(:queue_submission_eval_job)
        set_token student.token
        published_project_published_course.course.register student
        post :create, params: {project_id: published_project_published_course.id, file: @file}
        expect(MessagingService).to have_received(:queue_submission_eval_job)
      end.to change(Submission, :count).by(1)
      expect(response).to be_created
      expect(Submission.first.submitter.id).to eql student.id
    end
    it "allows teacher" do
      expect do
        set_token teacher.token
        post :create, params: {project_id: published_project_published_course.id, file: @file}
      end.to change(Submission, :count).by(1)
      expect(response).to be_created
      expect(Submission.first.submitter.id).to eql teacher.id
    end
    it "requires a file" do
      expect do
        set_token student.token
        published_project_published_course.course.register student
        post :create, params: {project_id: published_project_published_course.id}
      end.to change(Submission, :count).by(0)
      expect(response).to be_bad_request
    end
    it "can not submit to an unpublished project of a published course"  do
      expect do
        set_token student.token
        unpublished_project_published_course.course.register student
        post :create, params: {project_id: unpublished_project_published_course.id, file: @file}
      end.to change(Submission, :count).by(0)
      expect(response).to be_unprocessable
    end

    it "can not submit to a published project of an unpublished course" do
      expect do
        set_token student.token
        published_project_unpublished_course.course.register student
        post :create, params: {project_id: published_project_unpublished_course.id, file: @file}
      end.to change(Submission, :count).by(0)
      expect(response).to be_unprocessable
    end

    it "can not submit to an unpublished project of an unpublished course" do
      expect do
        set_token student.token
        unpublished_project_unpublished_course.course.register student
        post :create, params: {project_id: unpublished_project_unpublished_course.id, file: @file}
      end.to change(Submission, :count).by(0)
      expect(response).to be_unprocessable
    end

    it "queues submission evaluation job"  do
      allow(MessagingService).to receive(:queue_submission_eval_job)
      set_token student.token
      published_project_published_course.course.register student
      post :create, params: {project_id: published_project_published_course.id, file: @file}
      expect(MessagingService).to have_received(:queue_submission_eval_job)
    end
  end

  context 'download' do
    before(:each) do
      @submission =  FactoryBot.create(:submission_with_registration)
      @team_submission = FactoryBot.create(:team_submission)
    end

    it 'does not allow unauthorized' do
      get :download, params: {id: @submission.id}
      expect(response).to be_unauthorized
    end

    it 'allows submitter to download'do
      set_token @submission.submitter.token
      get :download, params: {id: @submission.id}
      expect(response).to be_success
    end

    it 'allows a teacher to download'  do
      set_token FactoryBot.create(:teacher).token
      get :download, params: {id: @submission.id}
      expect(response).to be_success
    end
    it 'does not allow an unverified user' do
      set_token FactoryBot.create(:teacher, verified: false).token
      get :download, params: {id: @submission.id}
      expect(response).to be_forbidden
    end
    it 'does not allow an unrelated student to download' do
      other = FactoryBot.create(:student)
      set_token other.token
      @submission.course.register other
      get :download, params: { id: @submission.id }
      expect(response).to be_forbidden
    end
    it 'does not allow student of same team to download' do
      other = FactoryBot.create(:student)
      set_token other.token
      @team_submission.course.register other, @team_submission.team

      get :download, params: { id: @team_submission.id }
      expect(response).to be_forbidden
    end
  end
  context 'show' do
    before :each do
      @submission = FactoryBot.create(:team_submission)
    end

    it 'does not allow unauthorized' do
      get :show, params: {id: @submission.id}
      expect(response).to be_unauthorized
    end

    it 'allows submitter to download' do
      set_token @submission.submitter.token
      get :show, params: {id: @submission.id}
      expect(response).to be_success
      expect(json_response).to include(
        :id, :submitter_id, :project_id, :created_at, :updated_at
      )
    end

    it 'does not allow student of same team show' do
      other = FactoryBot.create(:student)
      set_token other.token
      @submission.course.register other, @submission.team
      get :show, params: {id: @submission.id}
      expect(response).to be_forbidden
    end

    it 'allows a teacher to download' do
      set_token FactoryBot.create(:teacher).token
      get :show, params: {id: @submission.id}
      expect(response).to be_success
    end
    it 'does not allow an unverified user' do
      set_token FactoryBot.create(:teacher, verified: false).token
      get :show, params: {id: @submission.id}
      expect(response).to be_forbidden
    end
    it 'does not allow an unrelated student to download' do
      set_token FactoryBot.create(:student).token
      get :show, params: {id: @submission.id}
      expect(response).to be_forbidden
    end
  end


  context 'index' do
    before :each do
      @default_project = FactoryBot.create(:project, published: true, course: FactoryBot.create(:course, published: true))
      5.times { FactoryBot.create(:team_submission, project: @default_project) }
    end
    it 'does not allow unauthorized' do
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_unauthorized
    end
    it 'allows teacher' do
      teacher = FactoryBot.create(:teacher)
      set_token teacher.token
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_success
      expect(json_response[:submissions].size).to_not eql 0
    end
    it 'allows a student' do
      student = User.students.first
      set_token student.token
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_success
    end
    it 'has pagination' do
      student = User.students.first
      set_token student.token
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_success
      expect(json_response).to include(
        :submissions, :page, :page_size, :total_pages
      )
    end
    it 'Student cant see other students submission' do
      student = FactoryBot.create(:student, verified: true)
      @default_project.course.register student, Submission.first.team
      set_token student.token
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 0
    end

    it 'student cant query by team' do
      team = Submission.first.team
      student = FactoryBot.create(:student, verified: true)
      @default_project.course.register(student)
      set_token student.token
      get :index, params: {project_id: @default_project.id}
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 0
    end

    it 'students can not see own team submissions' do
      submission = Submission.first
      team = submission.team
      student = FactoryBot.create(:student, verified: true)
      submission.course.register student, team
      set_token student.token
      bypass_rescue
      get :index, params: { project_id: @default_project.id, submitter: { team: team } }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 0
    end

    it 'student can see own submissions' do
      student = FactoryBot.create(:student, verified: true)
      @default_project.course.register student
      3.times { FactoryBot.create(:team_submission, project: @default_project, submitter: student) }
      set_token student.token
      get :index, params: { project_id: @default_project.id }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 3
    end


    it 'teacher can query by name' do
      teacher = FactoryBot.create(:teacher, verified: true)
      student = FactoryBot.create(:student, verified: true)
      student_two = FactoryBot.create(:student, verified: true, name: student.name)
      @default_project.course.register student
      @default_project.course.register student_two
      4.times { FactoryBot.create(:team_submission, project: @default_project, submitter: student) }
      1.times { FactoryBot.create(:team_submission, project: @default_project, submitter: student_two) }
      set_token teacher.token
      get :index, params: { project_id: @default_project.id, submitter: { name: student.name } }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 5
      correct_ids = json_response[:submissions].reduce(true) do |memo, item|
        memo &&  [student.id, student_two.id].include?(item[:submitter_id])
      end
      expect(correct_ids).to be true
    end

    it 'teacher can query by team name' do
      teacher = FactoryBot.create(:teacher, verified: true)
      student = FactoryBot.create(:student, verified: true)
      student_two = FactoryBot.create(:student, verified: true)
      @default_project.course.register student, 'Dat gap'
      @default_project.course.register student_two, 'Dat gap'
      FactoryBot.create(:submission, project: @default_project, submitter: student)
      FactoryBot.create(:submission, project: @default_project, submitter: student_two)
      set_token teacher.token
      get :index, params: { project_id: @default_project.id, team: 'Dat gap' }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 2
      correct_ids = json_response[:submissions].reduce(true) do |memo, item|
        memo &&  [student.id, student_two.id].include?(item[:submitter_id])
      end
      expect(correct_ids).to be true
    end
    it 'teacher can query by team email' do
      teacher = FactoryBot.create(:teacher, verified: true)
      student = FactoryBot.create(:student, verified: true)
      @default_project.course.register student
      3.times { FactoryBot.create(:submission, project: @default_project, submitter: student) }
      set_token teacher.token
      get :index, params: { project_id: @default_project.id, submitter: { email: student.email } }
      expect(response).to be_success
      expect(json_response[:submissions].size).to eql 3
      correct_ids = json_response[:submissions].reduce(true) do |memo, item|
        memo &&  item[:submitter_id] == student.id
      end
      expect(correct_ids).to be true
    end
  end
end
