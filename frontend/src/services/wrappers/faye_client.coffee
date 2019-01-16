angular.module 'evaluator'
  .factory 'FayeClient', ($auth) ->
    faye = new Faye.Client '/faye'
    # Authentication extension
    authExtension =
      outgoing: (message, callback) ->
        if $auth.isAuthenticated()
          (message['data'] ?= {})['ext'] = {
            token: $auth.getToken()
          }
        callback message

    faye.addExtension authExtension
    return faye