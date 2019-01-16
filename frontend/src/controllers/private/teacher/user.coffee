angular.module 'evaluator'
  .controller 'UserController', ($scope, $stateParams, User, GUC_ID_REGEX,
    $state) ->
      $scope.processing = false
      $scope.loading = true
      $scope.user = new User {id: $stateParams.id}
      $scope.userData = {} # Used for password
      $scope.user.reload().then ->
        $scope.loading = false

      $scope.update = ->
        return if $scope.processing
        $scope.processing = true
        if $scope.user.student
          # Extract ID parts
          match = GUC_ID_REGEX.exec $scope.user.guc_id
          $scope.user.guc_prefix = match[1]
          $scope.user.guc_suffix = match[2]
        passwordChanged = $scope.userData.password? &&
          $scope.userData.password.length > 2
        if passwordChanged
          $scope.user.password = $scope.userData.password
        $scope.user.$update().then ->
          $scope.processing = false
        .catch (response) ->
          if response.status is 422
            $scope.processing = false
            $scope.error =
              ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
              .join ' '
          else if response.status is 404
            $scope.processing = false
            $scope.error = "User not found, may have been deleted"
          else
            $state.go '^.internal_error'
          
