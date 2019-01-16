angular.module 'evaluator'
  .factory 'ProjectSuitesResource', ($resource, endpoints) ->
    defaultParams =
      course_id: '@course_id'
    resourceActions =
      query:
        method: 'GET'
        isArray: false
        cache: true
      create:
        method: 'POST'
        isArray: false
        cache: false

    $resource endpoints.projectSuites.resourceUrl, defaultParams,
      resourceActions