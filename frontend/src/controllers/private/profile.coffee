angular.module 'evaluator'
  .controller 'ProfileController', ($scope, UserAuth, GUC_ID_REGEX, $state) ->
    $scope.processing = false
    $scope.user = UserAuth.user
    $scope.userData = {}
    $scope.loading = true
    $scope.user.reload().then ->
      $scope.loading = false


    $scope.update = ->
      return if $scope.processing
      $scope.processing = true
      if $scope.user.student
        match = GUC_ID_REGEX.exec $scope.user.guc_id
        $scope.user.guc_prefix = match[1]
        $scope.user.guc_suffix = match[2]
      passwordChanged = $scope.userData.password? &&
        $scope.userData.password.length > 2
      if passwordChanged
        $scope.user.password = $scope.userData.password
      $scope.user.$update().then ->
        postUpdate = ->
          $scope.user = UserAuth.user if passwordChanged
          $scope.processing = false

        if passwordChanged
          UserAuth.logout()
          UserAuth.login({
            email: $scope.user.email,
            password: $scope.userData.password
            }).then(postUpdate).catch ->
              $state.go 'public.internal_error'
        else
          postUpdate()
      .catch (response) ->
        if response.status is 422
          $scope.processing = false
          $scope.error =
            ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
            .join ' '
        else
          $state.go '^.internal_error'
