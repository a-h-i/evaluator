angular.module 'evaluator'
  .factory 'Bundle', (NotificationDispatcher, BundlesResource,
    configurations, moment) ->
      formatBytes = (bytes) ->
        if bytes == 0
          return '0 Byte'
        k = 1024
        dm = 3
        sizes = ['Bytes', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB', 'EiB', 'ZiB',
        'YiB']
        i = Math.floor(Math.log(bytes) / Math.log(k))
        parseFloat((bytes / Math.pow(k, i)).toFixed(dm)) + ' ' + sizes[i]

      class Bundle
        constructor: (@resource) ->
          NotificationDispatcher.subscribeProject {id: @project_id}, (e) ->
            configurations.then (config) =>
              if (e.type is
                config.notification_event_types.project_bundle_ready)
                  if e.payload.bundle.id is @id
                    @ready = true


        @property 'ready',
          get: ->
            @resource.ready
          set: (value) ->
            @resource.ready = value

        @property 'project_id',
          get: ->
            @resource.project_id

        @property 'project_name',
          get: ->
            @resource.project_name

        @property 'size',
          get: ->
            formatBytes(@resource.size_bytes)

        @property 'teams_only',
          get: ->
            @resource.teams_only

        @property 'created_at',
          get: ->
            moment(@resource.created_at).format("MMMM Do YYYY, h:mm:ss a")

        @property 'id',
          get: ->
            @resource.id

        @fromData: (data, args...) ->
          new Bundle(new ProjectResource(data), args...)