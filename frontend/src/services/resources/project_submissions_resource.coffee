angular.module 'evaluator'
  .factory 'ProjectSubmissionsResource', ($resource, endpoints) ->
    defaultParams =
      project_id: '@project_id'
    resourceActions =
      query:
        method: 'GET'
        isArray: false
        cache: true
      create:
        method: 'POST'
        isArray: false
        cache: false

    $resource endpoints.projectSubmissions.resourceUrl, defaultParams,
      resourceActions