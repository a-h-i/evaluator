angular.module 'evaluator'
  .controller 'ProjectController', ($scope, $stateParams, ProjectResource,
    UserAuth, ProjectSuitesResource, defaultPageSize, Pagination,
    Upload, endpoints, Project, Suite, $state, deletedSuiteIds, $mdDialog) ->

      $scope.isTeacher = UserAuth.user.teacher
      $scope.isAdmin = UserAuth.user.admin
      $scope.canAddSuite = $scope.isTeacher && $scope.isAdmin
      $scope.canEdit = $scope.isAdmin

      projectPromise = ProjectResource.get(
        id: $stateParams.id
        ).$promise

      $scope.loading = true
      unpublishedCallback = (project) ->
        if not $scope.isTeacher
          $state.go 'private.unpublished'

      projectPromise.then (project) ->
        $scope.project = new Project project, unpublishedCallback
        $scope.canAddSuite &= !$scope.project.published
        $scope.canEdit &= !$scope.project.published
        $scope.loading = false

      $scope.rerunSubmissions = ->
        $scope.loading = true
        $scope.project.reruning_submissions = true
        $scope.project.$update().then ->
          $scope.loading = false
          alert = $mdDialog.alert()
            .clickOutsideToClose(true)
            .title('Rerun Submissions')
            .textContent('Button will be available again when done')
            .ariaLabel('Rerun Submissions')
            .ok('Okay')
          $mdDialog.show(alert)
        , (response) ->
          $scope.project.reruning_submissions = false
          data = ''
          if response.status is 500
            $state.go '^.internal_error'
            return
          else if response.status is 422
            data =
              ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
              .join ' '
          else
            data = response.data.message.capitalize
          alert = $mdDialog.alert()
            .clickOutsideToClose(true)
            .title('Rerun Submissions')
            .textContent(data)
            .ariaLabel('Rerun Submissions')
            .ok('Okay')
          $mdDialog.show(alert)
          $scope.loading = false



      $scope.publish = ->
        $scope.loading = true
        $scope.project.published = true
        $scope.canEdit = false
        $scope.project.$update().then ->
          $scope.loading = false

      $scope.unpublish = ->
        $scope.loading = true
        $scope.project.published = false
        $scope.canEdit = UserAuth.user.admin
        $scope.project.$update().then ->
          $scope.loading = false

      ids = []
      $scope.suites = []
      $scope.suiteClasses = ['suite-accent-one', 'suite-accent-two',
      'suite-accent-three']

      deletedSuiteCallback = (id) ->
        deletedSuiteIds.push id
        _.remove $scope.suites, (suite) ->
          suite.id is id

      suiteFactory = (data) ->
        new Suite data, deletedSuiteCallback


      suitesPagination = new Pagination ProjectSuitesResource, 'test_suites',
      {project_id: $stateParams.id}, suiteFactory, defaultPageSize



      addSuitesCallback = (newSuites, begin) ->
        suites = _.filter newSuites, (suite) ->
          suite.id not in ids and suite.id not in deletedSuiteIds
        Array::push.apply ids, _.map suites, 'id'
        args = [begin, 0].concat suites
        $scope.suites.splice.apply $scope.suites, args

      $scope.loadingSuites = true

      # Load first page
      suitesPagination.page(1).then (data) ->
        $scope.loadingSuites = false
        addSuitesCallback data, $scope.suites.length

      # Callback for infinite scroll
      $scope.loadMore = ->
        $scope.scrollDisabled = true
        $scope.loadingSuites = true
        page = if suitesPagination.hasPages() then \
          suitesPagination.currentPage + 1 else suitesPagination.currentPage
        suitesPagination.page(page)
          .then (suites) ->
            $scope.loadingSuites = false
            addSuitesCallback suites, $scope.suites.length
            $scope.scrollDisabled = false


      $scope.showEditDialog = ($event) ->
        $scope.projectEditError = ''
        $mdDialog.show
          targetEvent: $event
          clickOutsideToClose: true
          scope: $scope
          preserveScope: true
          parent: angular.element(document.body)
          templateUrl: 'edit/project.html'


      $scope.update = ->
        return if $scope.processingProject
        $scope.processingProject = true
        success = (response) ->
          $mdDialog.hide()
          $scope.processingProject = false
        failure = (response) ->
          if response.status is 422
            $scope.projectEditError =
              ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
              .join ' '
            $scope.processingProject = false
          else
            $scope.suiteCreateError = response.data.message.capitalize
            $scope.processingProject = false
        $scope.project.$update().then success, failure


      $scope.newSuiteData = {}

      $scope.showAddDialog = ($event) ->
        $scope.newSuiteData = {}
        $scope.suiteCreateError = ''
        $mdDialog.show
          targetEvent: $event
          clickOutsideToClose: true
          scope: $scope
          parent: angular.element(document.body)
          preserveScope: true
          templateUrl: 'private/create/suite.html'

      $scope.submit = ->
        return if $scope.processingSuite
        $scope.processingSuite = true

        success = (response) ->
          $mdDialog.hide()
          $scope.processingSuite = false
          suite = new Suite response.data
          addSuitesCallback [suite], 0
        failure = (response) ->
          if response.status is 422
            $scope.suiteCreateError =
              ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
              .join ' '
            $scope.processingSuite = false
          else
            $scope.suiteCreateError = response.data.message.capitalize
            $scope.processingSuite = false
        Upload.upload(
          url: endpoints.projectSuites.resourceUrl.replace(':project_id',
          $stateParams.id)
          data: $scope.newSuiteData
        ).then(success, failure)
