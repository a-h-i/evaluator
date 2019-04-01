# == Schema Information
#
# Table name: test_suites
#
#  id         :bigint(8)        not null, primary key
#  project_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  timeout    :integer          default(60), not null
#  name       :text             not null
#  hidden     :boolean          default(TRUE), not null
#  file_name  :text             not null
#  mime_type  :text             not null
#  detail     :json             not null
#
# Indexes
#
#  index_test_suites_on_project_id_and_hidden_and_created_at  (project_id,hidden,created_at DESC)
#  test_suites_project_id_name_key                            (project_id,name) UNIQUE
#

require "rails_helper"

RSpec.describe TestSuite, type: :model do
  let(:subject) { FactoryBot.create(:test_suite) }
  it { should belong_to :project }
  it { should have_many :results }
  it { should validate_presence_of :name }
  it { should validate_presence_of :project }
  it { should validate_presence_of :detail }
  it { should validate_uniqueness_of(:name).scoped_to(:project_id).case_insensitive }

  it "sets mime type" do
    expect(subject.mime_type).to be_truthy
  end

  it "sets filename" do
    expect(subject.file_name).to be_truthy
  end

  it "saves file" do
    expect(File.exist?(subject.file_path)).to be true
  end

  describe "is_viewable_by?" do
    let(:teacher) {FactoryBot.create(:teacher)}
    let(:student) {FactoryBot.create(:student)}
    let(:hidden) {FactoryBot.create(:test_suite, hidden: true)}
    let(:not_hidden) {FactoryBot.create(:test_suite, hidden: false)}

    it 'should be viewable by student if public' do
      expect(not_hidden.is_viewable_by?(student)).to be true
    end
    it 'should be viewable by teacher if public' do
      expect(not_hidden.is_viewable_by?(teacher)).to be true
    end
    it 'should not be viewable by student if hidden' do
      expect(hidden.is_viewable_by?(student)).to be false
    end
    it 'should be viewable by teacher if hidden' do
      expect(hidden.is_viewable_by?(teacher)).to be true
    end
  end
end
