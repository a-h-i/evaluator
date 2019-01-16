angular.module 'evaluator'
  .factory 'ContactsResource', ($resource, endpoints) ->
    actions =
      create:
        method: 'POST'
        isArray: false
        cache: false
    $resource endpoints.contacts.resourceUrl, {}, actions