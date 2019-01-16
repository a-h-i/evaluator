angular.module 'evaluator'
  .factory 'Submission', (SubmissionResource, endpoints, Result,
    ResultsResource, Pagination, NotificationDispatcher,
    configurations, moment, User) ->
      class Submission
        constructor: (data, @deletedCallback=angular.noop) ->
          @resource = new SubmissionResource data
          @results = []
          @resultIds = []
          resultFactory = (data) ->
            new Result data
          if @resource.results
            @results = _.map @resource.results, resultFactory
            Array::push.apply @resultIds, _.map @resource.results, 'id'

          NotificationDispatcher.subscribeSubmission @, (e) =>
            configurations.then (config) =>
              if (e.type is
                  config.notification_event_types.submission_result_ready)
                    # Add result to results
                    if e.payload.result.id not in @resultIds
                      @resultIds.push e.payload.result.id
                      @results.push resultFactory e.payload.result
              else if (e.type is
                  config.notification_event_types.submission_deleted)
                    @deletedCallback @id


          @resultsPagination = new Pagination ResultsResource, 'results',
            {submission_id: @id,
            project_id: @resource.project_id}, resultFactory, 10000
          if @results.length is 0
            @resultsPagination.page(1).then (newResults) =>
              results = _.filter newResults, (result) =>
                result.id not in @resultIds
              Array::push.apply @resultIds, _.map results, 'id'
              @results.push.apply @results, results

        clearResults: ->
          @results.splice 0, @results.length

        @property 'num_suites',
          get: ->
            @resource.num_suites

        @property 'downloadUrl',
          get: ->
            endpoints.submission.downloadUrl.replace(':id', @id)

        @property 'rerunUrl',
          get: ->
            endpoints.submission.rerunUrl.replace(':id', @id)

        @property 'id',
          get: ->
            @resource.id

        @property 'submitter',
          get: ->
            @submitterInstance ||= new User @resource.submitter

        @property 'done',
          get: ->
            @results.length > 0 || @num_suites is 0

        @property 'compiled',
          get: ->
            _.every @results, 'compiled'

        @property 'status',
          get: ->
            if @num_suites is 0
              @SUCCESS_STATE
            else if not @done
              @PROCESSING_STATE
            else if @compiled
              if @grade == @max_grade
                @SUCCESS_STATE
              else
                @PARTIAL_STATE
            else
              @COMPILE_ERROR_STATE

        @property 'grade',
          get: ->
            @results.reduce (accum, result) ->
              accum + result.grade
            , 0


        @property 'max_grade',
          get: ->
            @results.reduce (accum, result) ->
              accum + result.max_grade
            , 0

        @property 'success',
          get: ->
            @status is @SUCCESS_STATE || @num_suites is 0

        @property 'partial',
          get: ->
            @status is @PARTIAL_STATE

        @property 'failure',
          get: ->
            @status is @COMPILE_ERROR_STATE

        @property 'processing',
          get: ->
            @status is @PROCESSING_STATE

        @property 'created_at',
          get: ->
            moment(@resource.created_at).format("MMMM Do YYYY, h:mm:ss a")

        @property 'created_at_as_date',
          get: ->
            @createdAtAsDateCache ||= moment(@resource.created_at).toDate()

        PARTIAL_STATE: 'partial-submission'
        SUCCESS_STATE: 'success-submission'
        COMPILE_ERROR_STATE: 'error-submission'
        PROCESSING_STATE: 'processing-submission'
