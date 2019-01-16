angular.module 'evaluator'
  .factory 'SubmissionResource', ($resource, endpoints) ->
    defaultParams =
      id: '@id'
    resourceActions =
      query:
        method: 'GET'
        isArray: false
        cache: true
      create:
        method: 'POST'
        isArray: false
        cache: false

    $resource endpoints.submission.resourceUrl, defaultParams,
      resourceActions