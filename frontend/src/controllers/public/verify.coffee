angular.module 'evaluator'
  .controller 'VerifyController', ($scope, $stateParams, $timeout,
    $state, $http, configurations,
    UserAuth, $auth, localStorageService, User) ->

      $scope.done = false
      $scope.message = "Account verified!" +
        " Please wait you will be redirected soon."
      $scope.success = false
      # Make request
      $http.put("/api/users/#{$stateParams.id}/verify.json",
        {token: $stateParams.token}
      ).then (response)->
        $scope.success = true
        $scope.done = true
        $timeout ->
          data = response.data.data
          UserAuth.setUserAndToken(data.user, data.token)
          $state.go 'private.courses'
        , 800
      .catch (response) ->
        $scope.success = false
        if response.status is 422
          configurations.then (config) ->
            $scope.message = "Incorrect token. Please note tokens expire " +
              "after #{config.verification_expiration / 60 / 60} hours."
            $scope.done = true

        else if response.status is 420
          configurations.then (config) ->
            $scope.message = "Can only send email once every " +
              "#{config.user_verification_resend_delay / 60} minutes"
            $scope.done = true
        else
          $state.go 'public.internal_error'
