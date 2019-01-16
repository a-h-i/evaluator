angular.module 'evaluator'
  .factory 'ResultsResource', ($resource, endpoints) ->
    defaultParams =
      project_id: '@project_id'
    actions =
      query:
        method: 'GET'
        isArray: false
        cache: true

    $resource endpoints.projectResults.resourceUrl, defaultParams, actions