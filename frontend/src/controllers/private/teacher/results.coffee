angular.module 'evaluator'
  .controller 'TeacherResultsController', ($scope, ProjectSubmissionsResource,
    CoursesResource, CourseProjectsResource, Pagination, Submission,
    defaultPageSize, deletedSubmissionIds) ->
      $scope.loadingSubmissions = false
      # Data used by the search form
      $scope.formData = {}
      $scope.searchData =
        name: ''
        email: ''
        guc_prefix: ''
        guc_suffix: ''
        team: ''

      # data used for searching for submissions
      $scope.submitterParams =
        name: null
        email: null
        guc_prefix: null
        guc_suffix: null
        team: null

      $scope.submissionParams =
        project_id: null
        "submitter[name]": null
        "submitter[email]": null
        "submitter[guc_prefix]": null
        "submitter[guc_suffix]": null
        "submitter[team]": null
        
        
      updateSubmitterParams = ->
        for key, value of $scope.submitterParams
          translatedKey = "submitter[#{key}]"
          $scope.submissionParams[translatedKey] = value
        return

      $scope.submissionClasses = ['submission-accent-one',
        'submission-accent-two', 'submission-accent-three']

      $scope.submissions = []

      deletedSubmissionCallback = (id) ->
        deletedSubmissionIds.push id
        _.remove $scope.submissions, (submission) ->
          submission.id is id

      $scope.$watch 'searchData', (newValue) ->
        changed = false
        for key, value of newValue
          oldParamValue = $scope.submitterParams[key]
          if value && value.length > 0
            $scope.submitterParams[key] = value
          else
            $scope.submitterParams[key] = null
          changed |= oldParamValue != $scope.submitterParams[key]
        updateSubmitterParams()
        $scope.reload() if changed
        return
      , true


      $scope.courseSearch = (nameQuery) ->
        CoursesResource.query({
          name: nameQuery,
          page: 1,
          page_size: 100
        }).$promise.then (data) ->
          data.courses

      $scope.projectSearch = (nameQuery, course) ->
        CourseProjectsResource.query({
          course_id: course.id,
          page: 1,
          page_size: 100,
          name: nameQuery
        }).$promise.then (data) ->
          data.projects

      submissionFactory = (data) ->
        return new Submission data, deletedSubmissionCallback

      addSubmissionsCallback = (newSubmissions) ->
        submissions = _.filter newSubmissions, (s) ->
          s.id not in deletedSubmissionIds
        args = [0, $scope.submissions.length].concat submissions
        $scope.submissions.splice.apply $scope.submissions, args
      
      $scope.submissionsPagination =
        new Pagination ProjectSubmissionsResource, 'submissions',
          $scope.submissionParams,
          submissionFactory, defaultPageSize

      $scope.reload = ->
        return if $scope.loadingSubmissions
        $scope.loadingSubmissions = true
        $scope.submissionsPagination.reload().then (submissions) ->
          $scope.loadingSubmissions = false
          addSubmissionsCallback submissions

      loadSubmissionsPage = (page) ->
        $scope.loadingSubmissions = true
        $scope.submissionsPagination.page(page).then (submissions) ->
          $scope.loadingSubmissions = false
          $scope.currentPage = page
          addSubmissionsCallback submissions

      $scope.currentPage = 1

      $scope.selectProject = (project) ->
        if project
          $scope.currentPage = 1
          $scope.submissionParams.project_id = project.id
          $scope.reload()
        else
          $scope.submissionParams.project_id = null

      $scope.backDisabled = ->
        $scope.currentPage is 1

      $scope.nextDisabled = ->
        $scope.currentPage >= $scope.submissionsPagination.totalPages

      $scope.next = ->
        if not $scope.nextDisabled()
          loadSubmissionsPage($scope.currentPage + 1)

      $scope.back = ->
        if not $scope.backDisabled()
          loadSubmissionsPage($scope.currentPage - 1)



