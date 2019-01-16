require 'rails_helper'

RSpec.describe SuitesProcessJob, type: :job do
  context 'basic functionality' do
    before :each do
      @suite = TestSuite.new
      @suite.project = FactoryGirl.create(:project)
      @suite.name = 'csv_test_suite'
      @suite.save!
      code = SuiteCode.new
      code.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                       '/files/test_suites/csv_test_suite.zip'))
      code.file_name = 'csv_test_suite.zip'
      code.mime_type = Rack::Mime.mime_type '.zip'
      code.test_suite = @suite
      code.save!
    end
    it 'should set max grade' do
      SuitesProcessJob.perform_now @suite
      @suite.reload
      expect(@suite.max_grade).to eql 40
    end
    it 'should set correct number of test cases' do
      SuitesProcessJob.perform_now @suite
      @suite.reload
      expect(@suite.suite_cases.size).to eql 1
      expect(@suite.suite_cases.first.name).to eql 'countLines'
      expect(@suite.suite_cases.first.grade).to eql 40
    end
    it 'should be marked as ready' do
      @suite.reload
      expect(@suite.ready).to be false
      SuitesProcessJob.perform_now @suite
      @suite.reload
      expect(@suite.ready).to be true
    end

    it 'sends suite_processed notification' do
      expect(@suite).to receive(:send_processed_notification).once
      SuitesProcessJob.perform_now @suite
    end
  end

  context 'large files' do
    before :each do
      @suite = TestSuite.new
      @suite.project = FactoryGirl.create(:project)
      @suite.name = 'public_tests'
      @suite.save
      code = SuiteCode.new
      code.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                       '/files/test_suites/PublicTests.zip'))
      code.file_name = 'PublicTests.zip'
      code.mime_type = Rack::Mime.mime_type '.zip'
      code.test_suite = @suite
      code.save
      @suite.suite_code = code
      @suite.save
    end

    it 'should set correct number of test cases' do
      SuitesProcessJob.perform_now @suite
      @suite.reload
      expect(@suite.suite_cases.count).to eql 43
    end
    it 'should have correct max grade' do
      SuitesProcessJob.perform_now @suite
      @suite.reload
      expect(@suite.max_grade).to eql 101
    end
    it 'should be marked as ready' do
      @suite.reload
      expect(@suite.ready).to be false
      SuitesProcessJob.perform_now @suite
      @suite.reload
      expect(@suite.ready).to be true
    end
    it 'sends suite_processed notification' do
      expect(@suite).to receive(:send_processed_notification).once
      SuitesProcessJob.perform_now @suite
    end
  end
end
