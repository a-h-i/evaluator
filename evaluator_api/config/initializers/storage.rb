Rails.application.configure do
  if Rails.env.production?
    config.submissions_path = ENV.fetch("EV_SUBMISSIONS_PATH", "/mnt/evaluator/submissions")
    config.test_suite_path = ENV.fetch("EV_TEST_SUITE_PATH", "/mnt/evaluator/test_suites")
  else
    config.submissions_path = Rails.root.join "tmp", 'storage', Rails.env.test?.to_s, "submissions"
    config.test_suite_path = Rails.root.join "tmp", 'storage', Rails.env.test?.to_s, "test_suites"
  end
  FileUtils.mkdir_p config.submissions_path
  FileUtils.mkdir_p config.test_suite_path

end
