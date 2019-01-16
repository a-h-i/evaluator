angular.module 'evaluator'
  .directive 'suite', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/suite.html'
      scope:
        suite: '=data'
        project: '=parentProject'
      controller: [ '$scope', 'FileSaver', 'UserAuth', 'endpoints', '$http',
        '$mdDialog',
        ($scope, FileSaver, UserAuth, endpoints, $http, $mdDialog) ->
          $scope.canDelete = UserAuth.user.teacher && $scope.suite.ready &&
            !$scope.project.published && UserAuth.user.admin
          $scope.canDownload = UserAuth.user.teacher || !$scope.suite.hidden
          $scope.download = ->
            download_url = endpoints.suite.downloadUrl.replace(':id',
              $scope.suite.id)
            $http.get(download_url, {responseType: "blob"})
              .then (response) ->
                try
                  filename = response.headers('content-Disposition').split(';')[1].split("=")[1]
                  filename = filename.substr(1, filename.length - 2)
                finally
                  filename or= "#{$scope.suite.name}.zip"
                  FileSaver.saveAs(response.data, filename)
          deleteSuite = ->
            return if not $scope.canDelete
            $scope.suite.$delete().catch (response) ->
              $scope.suite.ready = true

          $scope.showDeleteDialog = (event) ->
            confirm = $mdDialog.confirm()
              .title('Confirm Delete')
              .textContent(
                "Are you sure you want to delete #{$scope.suite.name}." +
                ' This action is irreversible and all associated results' +
                ' will be deleted as well.'
                ).ok('delete')
                .cancel('no!')
                .targetEvent(event)
            $mdDialog.show(confirm).then(deleteSuite, angular.noop)

      ]
