angular.module 'evaluator'
  .directive 'user', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/user.html'
      scope:
        user: '=data'
        noControls: '@?'
      controller: ['$scope', 'UserAuth', '$mdDialog',
        ($scope, UserAuth, $mdDialog) ->
          $scope.canEdit = UserAuth.user.admin
          $scope.canDelete = UserAuth.user.admin

          deleteUser = ->
            return if not $scope.canDelete
            $scope.user.$delete()

          $scope.showDeleteDialog = (event) ->
            confirm = $mdDialog.confirm()
              .title('Confirm Delete')
              .textContent(
                "Are you sure you want to delete #{$scope.user.full_name}." +
                ' This action is irreversible.'
                ).ariaLabel('Confirm Delete')
                .ok('yes delete')
                .cancel('no!')
                .targetEvent(event)
            $mdDialog.show(confirm).then(deleteUser, angular.noop)

      ]