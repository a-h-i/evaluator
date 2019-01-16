angular.module 'evaluator'
  .factory 'CoursesResource', ($resource, endpoints) ->
    coursesResourceDefaultParams =
      id: '@id'
    coursesResourceActions =
      query:
        method: 'GET'
        isArray: false
        cache: true
      update:
        method: 'PUT'
        isArray: false
        cache: false
      create:
        method: 'POST'
        isArray: false
        cache: false

    $resource endpoints.courses.resourceUrl, coursesResourceDefaultParams,
      coursesResourceActions