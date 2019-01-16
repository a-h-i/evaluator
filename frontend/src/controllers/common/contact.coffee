angular.module 'evaluator'
  .controller 'ContactController', ($scope, ContactsResource, $state, moment) ->
    $scope.contactData = {}
    $scope.processing = false
    $scope.error = ''
    $scope.send = ->
      return if $scope.processing
      $scope.processing = true
      $scope.error = ''
      $scope.contactData.reported_at = moment().format()
      $scope.contactData.title += " by #{$scope.contactData.email}"
      contact = new ContactsResource $scope.contactData
      success = ->
        $scope.error = ''
        $scope.processing = false
        $state.go '^.thanks_feedback'
      failure = (response) ->
        if response.status is 422
          $scope.courseCreateError =
            ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
            .join ' '
          $scope.processing = false
        else if response.status is 500
          $state.go '^.internal_error'
        else
          $scope.error = response.data.message.capitalize
          $scope.processing = false
      contact.$save success, failure
