angular.module 'evaluator'
  .config ($authProvider, apiHost) ->
    $authProvider.tokenPrefix = 'evaluator-sattelizer'
    $authProvider.httpInterceptor = true
    $authProvider.loginOnSignup = true
    $authProvider.storage = 'localStorage'
    $authProvider.baseUrl = apiHost
    $authProvider.signupUrl = 'users.json'
    $authProvider.loginUrl = 'tokens.json'

angular.module 'evaluator'
  .run ($rootScope, UserAuth, $analytics) ->
    $rootScope.userAuth = UserAuth
    $rootScope.$watch 'userAuth.signedIn', (newValue) ->
      if newValue
        $analytics.setUserProperties {
          email: UserAuth.user.email,
          name: UserAuth.user.full_name
        }
        $analytics.setUsername UserAuth.user.id

angular.module 'evaluator'
  .run ($rootScope, $state, UserAuth, redirect) ->
    # Authorization checks
    # applies to states that provide authRule method in their data object
    $rootScope.$on '$stateChangeStart', (e, toState, toParams) ->
      return if angular.isUndefined toState.data
      return if !angular.isFunction toState.data.authRule
      authStatus = toState.data.authRule UserAuth
      if !authStatus.allowed
        redirect.push
          state: toState
          params: toParams
        e.preventDefault()
        $state.go authStatus.to, authStatus.params

angular.module 'evaluator'
  .run ($rootScope, $state, UserAuth) ->
    $rootScope.$on 'unauthorizedResponse',  ->
      UserAuth.logout()
      $state.go 'public.login'

# HTTP Interceptor for 401s (expired)
angular.module 'evaluator'
  .config ($httpProvider) ->
    $httpProvider.interceptors.push ($q, $rootScope) ->
      interceptor =
        responseError: (response) ->
          if response.status is 401
            $rootScope.$emit 'unauthorizedResponse'
            $q.reject response
          else
            $q.reject response