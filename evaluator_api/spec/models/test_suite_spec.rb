# == Schema Information
#
# Table name: test_suites
#
#  id         :integer          not null, primary key
#  hidden     :boolean          default(TRUE), not null
#  max_grade  :integer          default(0), not null
#  name       :string           not null
#  ready      :boolean          default(FALSE), not null
#  timeout    :integer          default(60), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  project_id :integer
#
# Indexes
#
#  index_test_suites_on_hidden      (hidden)
#  index_test_suites_on_project_id  (project_id)
#
# Foreign Keys
#
#  fk_rails_...  (project_id => projects.id) ON DELETE => cascade
#

require 'rails_helper'

RSpec.describe TestSuite, type: :model do
  it { should belong_to :project }
  it { should have_one :suite_code }
  it { should have_many :suite_cases }
  it { should have_many :results }
  it { should validate_presence_of :name }

  it 'has a valid factory' do
    suite = FactoryGirl.build(:test_suite)
    expect(suite).to be_valid
  end
  it 'has a valid private factory' do
    suite = FactoryGirl.build(:private_suite)
    expect(suite).to be_valid
  end
  it 'has a valid public factory' do
    suite = FactoryGirl.build(:public_suite)
    expect(suite).to be_valid
  end

  context 'destroyable' do
    it 'false for published project' do
      suite = FactoryGirl.create(:test_suite,
                                 project: FactoryGirl.create(:project, published: true)
                                )
      expect(suite.destroyable?).to be false
    end
    it 'false for non ready suite' do
      suite = FactoryGirl.create(:test_suite, ready: false,
                                              project: FactoryGirl.create(:project, published: false)
                                )
      expect(suite.destroyable?).to be false
    end
    it 'true for ready suite unpublished project' do
      suite = FactoryGirl.create(:test_suite, ready: true,
                                              project: FactoryGirl.create(:project, published: false)
                                )
      expect(suite.destroyable?).to be true
    end
  end
end
