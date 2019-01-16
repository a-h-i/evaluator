angular.module 'evaluator'
  .factory 'ResultResource', (endpoints, $resource) ->
    params =
      id: '@id'

    $resource endpoints.result.resourceUrl, params
