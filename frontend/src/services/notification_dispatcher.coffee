angular.module 'evaluator'
  .factory 'NotificationDispatcher',  ->
    class NotificationDispatcher
      constructor: ->
        @subscribers = {}
        @listeners = {}


      # Generic handler
      handler: (url, message) ->
        (@listeners[url]or=[]).forEach (listener) ->
          listener(message)

      # Generic subscribe for all types
      # Used internally
      subscribe: (url, callback) ->
        (@listeners[url]or=[]).push callback
        # if url not of @subscribers
        #   receiveHandler = (message) =>
        #     @handler url, message
        #   FayeClient.subscribe url, receiveHandler

      subscribeSuite: (suite, callback) ->
        url = "/notifications/test_suites/#{suite.id}"
        @subscribe url, callback

      subscribeSubmission: (submission, callback) ->
        url = "/notifications/submissions/#{submission.id}"
        @subscribe url, callback

      subscribeCourse: (course, callback) ->
        url = "/notifications/courses/#{course.id}"
        @subscribe url, callback

      subscribeCourses: (callback) ->
        url = "/notifications/courses/all"
        @subscribe url, callback

      subscribeProject: (project, callback) ->
        url = "/notifications/projects/#{project.id}"
        @subscribe url, callback

      subscribeTeamJob: (job, callback) ->
        url = "/notifications/team_jobs/#{job.id}"
        @subscribe url, callback

      subscribeTeamGrade: (team_name, callback) ->
        url = "/notifications/teams/#{team_name.replace(' ', '_')}"
        @subscribe url, callback



    new NotificationDispatcher
