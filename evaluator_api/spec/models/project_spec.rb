# == Schema Information
#
# Table name: projects
#
#  id                   :integer          not null, primary key
#  due_date             :datetime         not null
#  name                 :string           not null
#  published            :boolean          default(FALSE), not null
#  quiz                 :boolean          default(FALSE), not null
#  reruning_submissions :boolean          default(FALSE), not null
#  start_date           :datetime         not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  course_id            :integer
#
# Indexes
#
#  index_projects_on_course_id   (course_id)
#  index_projects_on_due_date    (due_date)
#  index_projects_on_name        (name)
#  index_projects_on_published   (published)
#  index_projects_on_quiz        (quiz)
#  index_projects_on_start_date  (start_date)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe Project, type: :model do
  it { should belong_to :course }
  it { should have_many :submissions }
  it { should have_many :test_suites }
  it { should have_many :results }
  it { should validate_presence_of :name }
  it { should validate_presence_of :due_date }
  it { should validate_presence_of :course }

  describe 'validations' do
    let(:project) { FactoryGirl.build(:project) }
    it 'has a valid factory' do
      expect(project).to be_valid
    end
    context 'name is nil' do
      it 'should not be valid' do
        project.name = nil
        expect(project).to_not be_valid
      end
    end
    context 'due_date is nil' do
      it 'should not be valid' do
        project.due_date = nil
        expect(project).to_not be_valid
      end
    end

    context 'course is nil' do
      it 'should not be valid' do
        project.course = nil
        expect(project).to_not be_valid
      end
    end

    context 'unique name per course' do
      it 'should not be valid' do
        project.save!
        other = FactoryGirl.build(:project, name: project.name)
        other.course = project.course
        expect(other).to_not be_valid
      end
      it 'should be valid' do
        other = FactoryGirl.build(:project, name: project.name)
        expect(other).to be_valid
      end
    end
  end
  context 'query by due date' do
    before(:each) { Project.destroy_all }
    it 'should select due only' do
      FactoryGirl.create_list(:project, 5)
      FactoryGirl.create_list(:project, 3, due_date: 5.days.ago)
      projects = Project.due
      expect(projects.count).to eql 3
    end
    it 'should select non due only' do
      FactoryGirl.create_list(:project, 5)
      FactoryGirl.create_list(:project, 3, due_date: 5.days.ago)
      projects = Project.not_due
      expect(projects.count).to eql 5
    end
  end
  context 'query by published' do
    before(:each) { Project.destroy_all }
    it 'should select published only' do
      FactoryGirl.create_list(:project, 5, published: false)
      FactoryGirl.create_list(:project, 3, published: true)
      projects = Project.published
      expect(projects.count).to eql 3
    end
    it 'should select non published only' do
      FactoryGirl.create_list(:project, 5, published: false)
      FactoryGirl.create_list(:project, 3, published: true)
      projects = Project.not_published
      expect(projects.count).to eql 5
    end
  end

  context 'notification' do
    it 'sends created notification' do
      course = FactoryGirl.create(:course)
      expect(Notifications::CoursesController).to receive(:publish).once
      FactoryGirl.create(:project, course: course)
    end
    it 'sends published notification' do
      project = FactoryGirl.create(:project, published: false)
      expect(Notifications::ProjectsController).to receive(:publish).once
      expect(Notifications::CoursesController).to receive(:publish).once
      project.published = true
      expect(project.published_changed?).to be true
      project.save!
    end
    it 'sends unpublished notification' do
      project = FactoryGirl.create(:project, published: true)
      expect(Notifications::ProjectsController).to receive(:publish).once
      expect(Notifications::CoursesController).to receive(:publish).once
      project.published = false
      expect(project.published_changed?).to be true
      project.save
    end
    it 'sends deleted notification' do
      project = FactoryGirl.create(:project)
      expect(Notifications::ProjectsController).to receive(:publish).once
      project.destroy
    end
  end
end
