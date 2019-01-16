angular.module 'evaluator'
  .controller 'NavigationController', ($state, $scope, UserAuth) ->
    $scope.isTeacher = UserAuth.signedIn && UserAuth.user.teacher
    $scope.signedIn = ->
      UserAuth.signedIn
    $scope.currentUser = UserAuth.user
    $scope.logout = ->
      UserAuth.logout()
      $state.go 'public.login'
