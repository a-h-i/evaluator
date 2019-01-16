# Faye configurations
Rails.application.config.middleware.delete Rack::Lock

Faye.logger = Rails.logger
unless Rails.const_defined?(:Server) || !ENV['IS_SERVER'].nil?
  Faye.logger.debug 'Ensure reactor running!'
  Faye.ensure_reactor_running!
end
Rails.application.config.middleware.use FayeRails::Middleware, mount: '/faye', engine: {
  type: Faye::Redis,
  host: 'localhost'
}, timeout: 25 do
  map '/notifications/teams/**': Notifications::TeamsController
  map '/notifications/submissions/**': Notifications::SubmissionsController
  map '/notifications/test_suites/**': Notifications::TestSuitesController
  map '/notifications/projects/**': Notifications::ProjectsController
  map '/notifications/courses/**': Notifications::CoursesController
  map '/notifications/team_jobs/**': Notifications::TeamJobsController
end
