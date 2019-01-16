angular.module 'evaluator'
  .factory 'Suite', (SuiteResource, NotificationDispatcher, configurations) ->
    class Suite
      constructor: (data, @deletedCallback=angular.noop) ->
        @resource = new SuiteResource data
        NotificationDispatcher.subscribeSuite @, (e) =>
          configurations.then (config) =>
            if e.type is config.notification_event_types.test_suite_processed
              _.assign @resource, e.payload.test_suite
            else if e.type is config.notification_event_types.suite_deleted
              @deletedCallback @id

      $delete: (args...) ->
        @resource.ready = false
        @resource.$delete(args...)

      @property 'suite_cases',
        get: ->
          @resource.suite_cases

      @property 'id',
        get: ->
          @resource.id

      @property 'hidden',
        get: ->
          @resource.hidden

      @property 'ready',
        get: ->
          @resource.ready
        set: (value) ->
          @resource.ready = true

      @property 'max_grade',
        get: ->
          @resource.max_grade

      @property 'timout',
        get: ->
          @resource.timout

      @property 'name',
        get: ->
          @resource.name

      
    