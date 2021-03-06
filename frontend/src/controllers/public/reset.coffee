angular.module 'evaluator'
  .controller 'ResetController', ($scope, $stateParams, $timeout,
    $state, $http, configurations) ->
      $scope.processing = false
      $scope.done = false
      $scope.userData = {}


      $scope.resetPassword = ->
        return if $scope.processing
        $scope.processing = true
        $http.put("/api/users/confirm_reset.json",
          {token: $stateParams.token, password: $scope.userData.password}
        ).then ->
          $scope.processing = false
          $scope.done = true
          $timeout ->
            $state.go 'public.login'
          , 800
        .catch (response) ->
          if response.status is 404
            $scope.processing = false
            $scope.error = "User does not exist"
          else if response.status is 422
            $scope.processing = false
            $scope.error = response.data.message
          else if response.status is 420
            configurations.then (config) ->
              $scope.error = "Can only reset once every " +
                "#{config.pass_reset_resend_delay / 60} minutes"
              $scope.processing = false
          else
            $state.go 'public.internal_error'
