angular.module 'evaluator'
  .controller 'SendResetController', ($scope,  $timeout, $state,
    configurations, $http) ->
      $scope.processing = false
      $scope.done = false
      $scope.userData = {}

      $scope.confirm = ->
        return if $scope.processing
        $scope.processing = true
        $http.get(
          "/api/users/#{encodeURIComponent(btoa($scope.userData.email))}" +
          "/reset_password.json"
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
          else if response.status is 420
            configurations.then (config)->
              $scope.processing = false
              $scope.error = "Must wait #{config.pass_reset_expiration / 60}" +
                " minutes between requests"
          else if response.status is 422
            $scope.processing = false
            $scope.error = response.data.message
          else
            $state.go 'public.internal_error'
