angular.module 'evaluator'
  .controller 'SubmissionsController', ($scope, $stateParams, ProjectResource,
    ProjectSubmissionsResource, Pagination, defaultPageSize, Submission,
    $mdDialog, Upload, endpoints, UserAuth, $timeout, $http, Project
    NotificationDispatcher, configurations) ->

      $scope.canSubmit = ->
        $scope.project && !$scope.project.is_due &&
          $scope.project.started

      # $scope.teamGradeApplicable = UserAuth.user.student
      $scope.teamGradeApplicable = false
      $scope.teamGradeSubmissions = []
      $scope.submissions = []
      $scope.submissionClasses = ['submission-accent-one',
        'submission-accent-two', 'submission-accent-three']

      deletedSubmissionCallback = (id) ->
        _.remove $scope.submissions, (submission) ->
          submission.id is id

      submissionFactory = (data) ->
        new Submission data, deletedSubmissionCallback

      submissionsPagination = new Pagination ProjectSubmissionsResource,
        'submissions',
        {project_id: $stateParams.project_id,
        submitter_id: UserAuth.user.id
        }, submissionFactory, defaultPageSize

      addSubmissionsCallback = (newSubmissions) ->
        args = [0, $scope.submissions.length].concat newSubmissions
        $scope.submissions.splice.apply $scope.submissions, args

      changeTeamGrade = (submission) ->
        if $scope.teamGradeSubmissions.length is 0 ||
            $scope.teamGradeSubmissions[0].created_at_as_date <
            submission.created_at_as_date
              args = [0, $scope.teamGradeSubmissions.length].concat [submission]
              $scope.teamGradeSubmissions.splice.apply(
                $scope.teamGradeSubmissions, args)

      addNewSubmission = (submission) ->
        $scope.submissions.splice 0, 0, submission

      $scope.loadingSubmissions = true

      $scope.currentPage = 1

      loadSubmissionsPage = (page) ->
        submissionsPagination.page(page).then (submissions) ->
          $scope.loadingSubmissions = false
          $scope.currentPage = page
          addSubmissionsCallback submissions

      # Load first page
      loadSubmissionsPage $scope.currentPage

      $scope.backDisabled = ->
        $scope.currentPage == 1

      $scope.nextDisabled = ->
        $scope.currentPage >= submissionsPagination.totalPages


      $scope.next = ->
        if not $scope.nextDisabled()
          loadSubmissionsPage($scope.currentPage + 1)
      $scope.back = ->
        if not $scope.backDisabled()
          loadSubmissionsPage($scope.currentPage - 1)

      $scope.newSubmissionData = {}


      $scope.submit = ->
        return if $scope.processingSubmission
        $scope.processingSubmission = true
        failure = (response) ->
          if response.status is 422
            $scope.submissionCreateError =
              ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
              .join ' '
            $scope.processingSubmission = false
          else
            $scope.submissionCreateError = response.data.message.capitalize
            $scope.processingSubmission = false
          return response

        success = (response) ->
          submission = new Submission response.data
          $mdDialog.hide()
          $scope.processingSubmission = false
          addNewSubmission submission

        Upload.upload(
          url: endpoints.projectSubmissions.resourceUrl.replace(':project_id',
          $stateParams.project_id)
          data: $scope.newSubmissionData
        ).then(success, failure)


      $scope.showAddDialog = ($event)->
        $scope.newSubmissionData = {}
        $scope.submissionCreateError = ''
        $mdDialog.show
          targetEvent: $event
          clickOutsideToClose: true
          scope: $scope
          parent: angular.element(document.body)
          preserveScope: true
          templateUrl:'private/create/submission.html'

      teamGradeCallback = (teamSubmission) ->
        submission = new Submission teamSubmission
        changeTeamGrade submission

      $http.get(
        endpoints.teamGrades.latest.replace(':project_id',
        $stateParams.project_id)
        ).then (response) ->
          teamGradeCallback response.data

      $scope.loading = true
      projectPromise = ProjectResource.get(
        id: $stateParams.project_id
        ).$promise
      projectPromise.then (project) ->
        $scope.project = new Project project
        $scope.loading = false
        if $scope.teamGradeApplicable
          NotificationDispatcher.subscribeTeamGrade UserAuth.user.team, (e) ->
            configurations.then (config) ->
              if (e.type is
                  config.notification_event_types.team_grade_created)
                    if e.payload.submission.project_id is $scope.project.id
                      teamGradeCallback e.payload.submission
