angular.module 'evaluator'
  .factory 'Project', (moment, ProjectResource,
    NotificationDispatcher, configurations) ->
      class Project
        constructor: (@resource, @unpublishedCallback=angular.noop,
          @newSuiteCallback=angular.noop,
          @processedSuiteCallback=angular.noop,
          @deletedCallback=angular.noop) ->
            NotificationDispatcher.subscribeProject @, (e) =>
              configurations.then (config) =>
                if (e.type is
                    config.notification_event_types.project_published)
                      _.assign @resource, e.payload.project
                else if (e.type is
                  config.notification_event_types.project_unpublished)
                    _.assign @resource, e.payload.project
                    @unpublishedCallback @
                else if (e.type is
                  config.notification_event_types.suite_created)
                    @newSuiteCallback e.payload.test_suite
                else if (e.type is
                  config.notification_event_types.test_suite_processed)
                    @processedSuiteCallback e.payload.test_suite
                else if (e.type is
                  config.notification_event_types.project_deleted)
                    @deletedCallback @id


        @property 'due_date',
          get: ->
            @dueDateCache ||=
              moment(@resource.due_date).format("MMMM Do YYYY, h:mm:ss a")
          set: (value) ->
            @resource.due_date = value

        @property 'reruning_submissions',
          get: ->
            @resource.reruning_submissions
          set: (value) ->
            @resource.reruning_submissions = value


        @property 'start_date',
          get: ->
            @startDateCache ||=
              moment(@resource.start_date).format("MMMM Do YYYY, h:mm:ss a")
          set: (value) ->
            @$resource.start_date = value

        @property 'due_date_as_date',
          get: ->
            @dueDateAsDateCache ||= moment(@resource.due_date).toDate()
          set: (value) ->
            @resource.due_date = value

        @property 'start_date_as_date',
          get: ->
            @startDateAsDateCache ||= moment(@resource.start_date).toDate()
          set: (value) ->
            @resource.start_date = value

        @property 'published',
          get: ->
            @resource.published
          set: (value) ->
            @resource.published = value

        @property 'name',
          get: ->
            @resource.name

        @property 'quiz',
          get: ->
            @resource.quiz

        @property 'is_due',
          get: ->
            @due_date_as_date < new Date()
        @property 'started',
          get: ->
            @start_date_as_date < new Date()

        @property 'id',
          get: ->
            @resource.id

        $update: (args...) ->
          @resource.$update(args...)


        @fromData: (data, args...) ->
          new Project(new ProjectResource(data), args...)
