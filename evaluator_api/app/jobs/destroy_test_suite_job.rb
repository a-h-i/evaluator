class DestroyTestSuiteJob < ActiveJob::Base
  queue_as :default

  rescue_from(ActiveJob::DeserializationError) do
  end

  def perform(test_suite)
    project = test_suite.project
    project.with_lock('FOR UPDATE') do
      test_suite.destroy
    end
  end
end
