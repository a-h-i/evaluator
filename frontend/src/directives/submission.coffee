angular.module 'evaluator'
  .directive 'submission', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/submission.html'
      scope:
        submission: '=data'
        includeSubmitter: '@?'
        noDownload: '@?'
        rerunEnabled: '@?'
      controller: ['$scope', 'FileSaver', '$http',
        ($scope, FileSaver, $http) ->
          $scope.rerun = ->
            $scope.submission.clearResults()
            $http.get($scope.submission.rerunUrl)
          $scope.download = ->
            $http.get($scope.submission.downloadUrl,
              {responseType: 'blob'})
              .then (response) ->
                try
                  filename = response.headers('content-Disposition').split(';')[1].split("=")[1]
                  filename = filename.substr(1, filename.length - 2)
                finally
                  filename or= "submission_#{$scope.submission.id}.zip"
                  FileSaver.saveAs(response.data, filename)
        ]
