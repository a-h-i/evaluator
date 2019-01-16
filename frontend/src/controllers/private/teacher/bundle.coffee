angular.module 'evaluator'
  .controller 'BundleDownloadController', ($scope, FileSaver, $http,
    $stateParams, endpoints) ->
      $scope.processing = true
      $http.get(endpoints.project.bundle.downloadUrl.replace(':id',
        $stateParams.id),
        {responseType: 'blob'}
        ).then (response) ->
          $scope.processing = false
          try
            filename = response.headers('content-Disposition').split(';')[1].split("=")[1]
            filename = filename.substr(1, filename.length - 2)
          finally
            filename or= "bundle_#{$stateParams.id}.tar.gz"
          FileSaver.saveAs(response.data, filename)
