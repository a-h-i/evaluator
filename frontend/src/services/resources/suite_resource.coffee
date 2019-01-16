angular.module 'evaluator'
  .factory 'SuiteResource', ($resource, endpoints) ->
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

    $resource endpoints.suite.resourceUrl, defaultParams, actions