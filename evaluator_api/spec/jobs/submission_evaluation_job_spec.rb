require 'rails_helper'

RSpec.describe SubmissionEvaluationJob, type: :job do
  context 'csv' do
    before :each do
      # setup project
      @project = FactoryGirl.create(:project, published: true,
                                              course: FactoryGirl.create(:course, published: true))
      # Setup test suite
      @suite = TestSuite.new
      @suite.project = @project
      @suite.name = 'csv_test_suite'
      @suite.save!
      code = SuiteCode.new
      code.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                       '/files/test_suites/csv_test_suite.zip'))
      code.file_name = 'csv_test_suite.zip'
      code.mime_type = Rack::Mime.mime_type '.zip'
      code.test_suite = @suite
      code.save!
      # Run process job
      SuitesProcessJob.perform_now @suite
    end

    context 'csv correct spaces' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'csv submission correct.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'csv_submission_correct.zip'))
        solution.save!
      end

      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).once
        SubmissionEvaluationJob.perform_now @submission
      end

      it 'creates a result' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(1)
      end

      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.grade).to eql @suite.max_grade
      end

      it 'sets correct result attributes and cases' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.compiled).to be true
        expect(result.success).to be true
        result_case = result.test_cases.first
        expect(result_case.grade).to eql 40
        expect(result_case.java_klass_name).to eql 'TestFileReadTest'
        expect(result_case.name).to eql 'countLines'
        expect(result_case.max_grade).to eql 40
        expect(result_case.passed).to be true
      end
    end

    context 'csv_submission_correct' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'csv_submission_correct.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'csv_submission_correct.zip'))
        solution.save!
      end

      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).once
        SubmissionEvaluationJob.perform_now @submission
      end

      it 'creates a result' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(1)
      end

      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.grade).to eql @suite.max_grade
      end

      it 'sets correct result attributes and cases' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        puts result.compiler_stdout
        expect(result.compiled).to be true
        expect(result.success).to be true
        result_case = result.test_cases.first
        expect(result_case.grade).to eql 40
        expect(result_case.java_klass_name).to eql 'TestFileReadTest'
        expect(result_case.name).to eql 'countLines'
        expect(result_case.max_grade).to eql 40
        expect(result_case.passed).to be true
      end
    end

    context 'csv_submission_error' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'csv_submission.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'csv_submission_error.zip'))
        solution.save!
      end
      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).once
        SubmissionEvaluationJob.perform_now @submission
      end
      it 'creates a result' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(1)
      end
      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.grade).to eql 0
      end

      it 'is not successfull' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.success).to be false
      end

      it 'did not compile' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.compiled).to be false
      end

      it 'has correct compiler output' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.compiler_stdout).to include('TestFileRead.java:15: error:')
      end
    end

    context 'csv_submission' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'csv_submission.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'csv_submission.zip'))
        solution.save!
      end
      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).once
        SubmissionEvaluationJob.perform_now @submission
      end

      it 'creates a result' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(1)
      end

      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.grade).to eql 0
      end

      it 'sets correct result attributes and cases' do
        SubmissionEvaluationJob.perform_now @submission
        result = @submission.results.first
        expect(result.compiled).to be true
        expect(result.success).to be false
        result_case = result.test_cases.first
        expect(result_case.grade).to eql 0
        expect(result_case.java_klass_name).to eql 'TestFileReadTest'
        expect(result_case.name).to eql 'countLines'
        expect(result_case.max_grade).to eql 40
        expect(result_case.passed).to be false
      end
    end
  end

  context 'zork' do
    before :each do
      @project = FactoryGirl.create(:project, published: true,
                                              course: FactoryGirl.create(:course, published: true))
      @publicSuite = TestSuite.new
      @publicSuite.project = @project
      @publicSuite.name = 'zorkPublic'
      @publicSuite.save!
      code = SuiteCode.new
      code.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                       '/files/test_suites/zorkPublic.zip'))
      code.file_name = 'zorkPublic.zip'
      code.mime_type = Rack::Mime.mime_type '.zip'
      code.test_suite = @publicSuite
      code.save!
      @privateSuite = TestSuite.new
      @privateSuite.name = 'zorkPrivate'
      @privateSuite.project = @project
      @privateSuite.save!
      privateCode = SuiteCode.new
      privateCode.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                              '/files/test_suites/zorkPrivate.zip'))
      privateCode.file_name = 'zorkPrivate.zip'
      privateCode.mime_type = Rack::Mime.mime_type '.zip'
      privateCode.test_suite = @privateSuite
      privateCode.save!
      SuitesProcessJob.perform_now @publicSuite
      SuitesProcessJob.perform_now @privateSuite
    end
    context 'correct submission' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'zork_submission_correct.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'zork_submission_correct.zip'))
        solution.save!
      end

      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).twice
        SubmissionEvaluationJob.perform_now @submission
      end

      it 'creates two results' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(2)
      end

      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        results = @submission.results.to_a
        ok = results.all? { |r| r.grade == r.max_grade }
        expect(ok).to be true
      end
    end
  end

  context 'milestone 0' do
    before :each do
      @project = FactoryGirl.create(:project, published: true,
                                              course: FactoryGirl.create(:course, published: true))
      @publicSuite = TestSuite.new
      @publicSuite.project = @project
      @publicSuite.name = 'M1PublicTest'
      @publicSuite.save!
      code = SuiteCode.new
      code.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                       '/files/test_suites/M1PublicTest.zip'))
      code.file_name = 'M1PublicTest.zip'
      code.mime_type = Rack::Mime.mime_type '.zip'
      code.test_suite = @publicSuite
      code.save!
      @privateSuite = TestSuite.new
      @privateSuite.name = 'M1PrivateTest'
      @privateSuite.project = @project
      @privateSuite.save!
      privateCode = SuiteCode.new
      privateCode.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                              '/files/test_suites/M1PrivateTest.zip'))
      privateCode.file_name = 'M1PrivateTest.zip'
      privateCode.mime_type = Rack::Mime.mime_type '.zip'
      privateCode.test_suite = @privateSuite
      privateCode.save!
      SuitesProcessJob.perform_now @publicSuite
      SuitesProcessJob.perform_now @privateSuite
    end
  
    context 'submission_3585.zip (missing public results)' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'submission_3585.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'submission_3585.zip'))
        solution.save!
      end
  
      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).twice
        SubmissionEvaluationJob.perform_now @submission
      end
  
      it 'creates two results' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(2)
      end
  
      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        pub_result = @submission.results.where(test_suite: @publicSuite).first
        priv_result = @submission.results.where(test_suite: @privateSuite).first
        expect(pub_result.success).to be true
        expect(pub_result.compiled).to be true
        expect(pub_result.grade).to eql 81
        expect(priv_result.success).to be false
        expect(priv_result.compiled).to be true
        expect([64, 65]).to include(priv_result.grade)
      end
  
    end
  
    context 'submission_2219.zip (build failed)' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'submission_2219.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'submission_2219.zip'))
        solution.save!
      end
  
      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).twice
        SubmissionEvaluationJob.perform_now @submission
      end
  
      it 'creates two results' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(2)
      end
  
      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        pub_result = @submission.results.where(test_suite: @publicSuite).first
        priv_result = @submission.results.where(test_suite: @privateSuite).first
        expect(pub_result.success).to be true
        expect(pub_result.compiled).to be true
        expect(pub_result.grade).to eql 81
        expect(priv_result.success).to be true
        expect(priv_result.compiled).to be true
        expect(priv_result.grade).to eql 66
      end
  
    end
  
    context 'submission_2486.zip (build failed)' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'submission_2486.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'submission_2486.zip'))
        solution.save!
      end
  
      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        pub_result = @submission.results.where(test_suite: @publicSuite).first
        priv_result = @submission.results.where(test_suite: @privateSuite).first
        expect(pub_result.success).to be false
        expect(pub_result.compiled).to be false
        expect(pub_result.grade).to eql 0
        expect(priv_result.success).to be false
        expect(priv_result.compiled).to be false
        expect(priv_result.grade).to eql 0
      end
  
    end
  
    context 'submission_2732.zip (build failed)' do
      before :each do
        @submission = Submission.new
        @submission.submitter = FactoryGirl.create(:student, verified: true)
        @submission.project = @project
        @submission.save!
        solution = Solution.new
        solution.file_name = 'submission_2732.zip'
        solution.mime_type = Rack::Mime.mime_type '.zip'
        solution.submission = @submission
        solution.code = IO.binread(File.join(Rails.root, 'spec', 'fixtures',
                                             'files', 'submissions', 'submission_2732.zip'))
        solution.save!
      end
  
      it 'sends new result notification' do
        expect(@submission).to receive(:send_new_result_notification).twice
        SubmissionEvaluationJob.perform_now @submission
      end
  
      it 'creates two results' do
        expect do
          SubmissionEvaluationJob.perform_now @submission
        end.to change(Result, :count).by(2)
      end
  
      it 'sets correct grade' do
        SubmissionEvaluationJob.perform_now @submission
        pub_result = @submission.results.where(test_suite: @publicSuite).first
        priv_result = @submission.results.where(test_suite: @privateSuite).first
        expect(pub_result.success).to be true
        expect(pub_result.compiled).to be true
        expect(pub_result.grade).to eql 81
        expect(priv_result.success).to be false
        expect(priv_result.compiled).to be true
        expect([65, 64]).to include(priv_result.grade)
      end
  
    end
  end
end
