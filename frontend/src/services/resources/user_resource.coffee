angular.module 'evaluator'
  .factory 'UsersResource', ($resource, endpoints) ->
    usersResourceDefaultParams =
      id: '@id'
    usersResourceActions =
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
      delete:
        method: 'DELETE'
        isArray: false
        cache: false

    $resource endpoints.users.resourceUrl, usersResourceDefaultParams,
      usersResourceActions