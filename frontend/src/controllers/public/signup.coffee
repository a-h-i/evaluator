angular.module 'evaluator'
  .controller 'SignupController', ($scope, UserAuth, $state, GUC_ID_REGEX) ->
    STUDENT_EMAIL_REGEX = /^[a-zA-Z\.\-]+@student.guc.edu.eg$/


    $scope.processing = false
    $scope.userData = {}
    $scope.isStudent = ->
      STUDENT_EMAIL_REGEX.test $scope.userData.email

    $scope.submit = ->
      return if $scope.processing
      $scope.processing = true
      if $scope.isStudent()
        match = GUC_ID_REGEX.exec $scope.userData.guc_id
        $scope.userData.guc_prefix = match[1]
        $scope.userData.guc_suffix = match[2]
      UserAuth.signup $scope.userData
        .then ->
          $state.go 'public.welcome'
        .catch (response) ->
          if response.status is 422
            $scope.processing = false
            $scope.error =
              ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
              .join ' '
          else
            $state.go 'public.internal_error'
