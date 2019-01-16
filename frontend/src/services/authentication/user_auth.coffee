angular.module 'evaluator'
  .factory 'UserAuth', ($auth, $q, configurations, localStorageService, User) ->
    class UserService
      constructor: ->
        
      @property 'signedIn',
        get: ->
          $auth.isAuthenticated()

      login: (info, expiration) ->
        deferred = $q.defer()
        configurations.then (config) =>
          expiration ||= config.default_token_exp
          info.expiration = expiration
          $auth.login({token: info})
            .then (response) =>
              @currentUserData = response.data.user
              localStorageService.set 'currentUser', @currentUserData
              @currentUser = new User @currentUserData
              deferred.resolve response
            .catch (response) ->
              deferred.reject response
        .catch (response) ->
          deferred.reject response
        return deferred.promise

      signup: (data) ->
        $auth.signup data
          .then (response) =>
            @currentUserData = response.data.user
            localStorageService.set 'currentUser', @currentUserData
            @currentUser = new User @currentUserData
            return response


      logout: ->
        @currentUser = undefined
        @currentUserData = undefined
        localStorageService.remove 'currentUser'
        if @signedIn
          $auth.logout()

      getUser: ->
        if not angular.isUndefined @currentUser
          return @currentUser
        else
          @currentUser = new User localStorageService.get 'currentUser'
      setUserAndToken: (userData, tokenDat) ->
        @currentUserData = userData
        localStorageService.set 'currentUser', @currentUserData
        @currentUser = new User @currentUserData
        $auth.setToken(tokenDat)

      @property 'user',
        get: ->
          @getUser()

        
    return new UserService
    