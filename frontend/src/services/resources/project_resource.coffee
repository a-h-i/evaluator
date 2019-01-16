angular.module 'evaluator'
  .factory 'ProjectResource', ($resource, endpoints) ->
    defaultParams =
      id: '@id'

    actions =
      update:
        method: 'PUT'
        isArray: false
        cache: false
      create:
        method: 'POST'
        isArray: false
        cache: false

    $resource endpoints.project.resourceUrl, defaultParams, actions