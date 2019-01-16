angular.module 'evaluator'
  .factory 'BundlesResource', ($resource, endpoints) ->
    defaultParams =
      id: '@id'
    actions =
      query:
        method: 'GET'
        isArray: false
        cache: true

    $resource endpoints.project.bundle.resourceUrl, defaultParams, actions