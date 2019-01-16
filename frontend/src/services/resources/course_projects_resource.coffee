angular.module 'evaluator'
  .factory 'CourseProjectsResource', ($resource, endpoints) ->
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

    $resource endpoints.courseProjects.resourceUrl, defaultParams,
      resourceActions