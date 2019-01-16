angular.module 'evaluator'
  .factory 'configurations', (endpoints, $http) ->
    $http.get endpoints.configurations.index, {cache: true}
      .then (response) ->
        return response.data