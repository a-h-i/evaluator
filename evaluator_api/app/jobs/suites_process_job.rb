class SuitesProcessJob < ActiveJob::Base
  queue_as :default
  MODIFIERS_REGEX = /(public|private|protected|static|final|native|synchronized|abstract|transient)/
  TYPE_REGEX = /\w+/
  IDENTIFIER_REGEX = /\w+/
  ANNOTATION_REGEX = /\s*@Test.*/
  METHOD_REGEX = /\s*#{MODIFIERS_REGEX}*\s+#{TYPE_REGEX}\s+(?<name>#{IDENTIFIER_REGEX})\s*\(.*\)/
  GRADE_REGEX = /\/\*[^\/]*@grade\s+(?<grade>\w+)[^\/]*\*\//m
  REGEX = /#{GRADE_REGEX}?#{ANNOTATION_REGEX}#{METHOD_REGEX}/m

  rescue_from(UnzipError) do |_ex|
    suite = arguments[0]
    test_suite.with_lock('FOR UPDATE') do
      test_suite.max_grade = 0
      test_suite.ready = true
      test_suite.name += ' Failed to unzip'
      test_suite.save!
    end
  end

  def perform(test_suite)
    test_suite.with_lock('FOR UPDATE') do
      IO.binwrite(test_suite.suite_code.file_name, test_suite.suite_code.code)
      `unzip '#{test_suite.suite_code.file_name}'`
      raise UnzipError, "suite #{test_suite.suite.id}" if $CHILD_STATUS.exitstatus != 0
      FileUtils.remove test_suite.suite_code.file_name
      test_suite.max_grade = 0
      Dir.glob '**/*.java' do |filename|
        File.read(filename).scan(REGEX).each do |match|
          namePos = REGEX.named_captures['name'].first - 1
          name = match[namePos]
          gradePos = REGEX.named_captures['grade'].first - 1
          grade = match[gradePos]
          grade ||= 1
          suite_case = SuiteCase.new
          suite_case.test_suite = test_suite
          suite_case.name = name
          suite_case.grade = grade
          suite_case.save!
          test_suite.max_grade += suite_case.grade
        end
      end
      test_suite.ready = true
      test_suite.save!
    end
    test_suite.send_processed_notification
  end

  around_perform do |_job, block|
    @old_dir = Dir.pwd
    @dir = Dir.mktmpdir
    begin
      Dir.chdir @dir
      block.call
    ensure
      Dir.chdir @old_dir
      FileUtils.remove_entry_secure @dir
    end
  end
end
