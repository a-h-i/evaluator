angular.module 'evaluator'
  .controller 'CourseController', ($scope, CoursesResource, $stateParams,
    UserAuth, CourseProjectsResource, defaultPageSize, Pagination,
    ngDialog, Project, Course, NotificationDispatcher, configurations) ->

    $scope.isTeacher = UserAuth.user.teacher
    $scope.canAddProject = $scope.isTeacher
    ids = []
    $scope.projects = []
    $scope.projectClasses = ['project-accent-one', 'project-accent-two',
    'project-accent-three']

    coursePromise = CoursesResource.get(
      id: $stateParams.id
    ).$promise


    $scope.loading = true
    coursePromise.then (course) ->
      $scope.course = new Course course
      $scope.loading = false

    $scope.publish = ->
      $scope.loading = true
      $scope.course.published = true
      $scope.course.$update().then ->
        $scope.loading = false

    deletedProjectCallback = (projectID) ->
      _.remove ids, (id) ->
        id is projectID
      _.remove $scope.projects, (project) ->
        project.id is projectID

    newProjectCallback = (project) ->
      if $scope.isTeacher || project.published
        $scope.addProjectsCallback [project], 0

    publishedProjectCallback = (project) ->
      if not $scope.isTeacher
        $scope.addProjectsCallback [project], 0

    unpublishedProjectCallback = (project) ->
      if not $scope.isTeacher
        deletedProjectCallback project.id

    projectFactory = (data) ->
      Project.fromData data, unpublishedProjectCallback,
        angular.noop, angular.noop, deletedProjectCallback

    projectsPagination = new Pagination CourseProjectsResource, 'projects',
    {course_id: $stateParams.id}, projectFactory, defaultPageSize

    # Add projects to $scope.projects at begin (index)
    addProjectsCallback = (newProjects, begin) ->
      projects = _.filter newProjects, (project) ->
        project.id not in ids
      Array::push.apply ids, _.map projects, 'id'
      args = [begin, 0].concat projects
      $scope.projects.splice.apply $scope.projects, args

    $scope.addProjectsCallback = addProjectsCallback

    NotificationDispatcher.subscribeCourse $stateParams, (e) ->
      configurations.then (config) ->
        if e.type is config.notification_event_types.project_published
          project = projectFactory e.payload.project
          publishedProjectCallback project
        else if e.type is config.notification_event_types.project_created
          project = projectFactory e.payload.project
          newProjectCallback project

    $scope.loadingProjects = true
    # Load first page
    projectsPagination.page(1).then (data) ->
      $scope.loadingProjects = false
      addProjectsCallback data, $scope.projects.length

    # Callback for infinite scroll
    $scope.loadMore = ->
      $scope.scrollDisabled = true
      $scope.loadingProjects = true
      page = if projectsPagination.pageSize < defaultPageSize then \
        projectsPagination.currentPage else projectsPagination.currentPage + 1
      projectsPagination.page(page)
        .then (projects) ->
          $scope.loadingProjects = false
          addProjectsCallback projects, $scope.projects.length
          $scope.scrollDisabled = false


    $scope.newProjectData = {}

    $scope.showAddDialog = ->
      return if $scope.newProjectDialog && ngDialog.isOpen($scope.newProjectDialog.id)
      $scope.newProjectData = {}
      $scope.projectCreateError = ''
      $scope.newProjectDialog = ngDialog.open
        template: 'private/create/project.html'
        scope: $scope

    $scope.submit = ->
      return if $scope.processingProject
      $scope.processingProject = true
      $scope.newProjectData.start_date.setHours(0)
      $scope.newProjectData.start_date.setMinutes(0)
      $scope.newProjectData.start_date.setSeconds(0)
      $scope.newProjectData.due_date.setHours(0)
      $scope.newProjectData.due_date.setMinutes(0)
      $scope.newProjectData.due_date.setSeconds(0)
      project = new CourseProjectsResource $scope.newProjectData
      project.course_id = $stateParams.id
      success = (project) ->
        $scope.newProjectDialog.close()
        $scope.processingProject = false
        addProjectsCallback [projectFactory project], 0
      failure = (response) ->
        if response.status is 422
          $scope.projectCreateError = ("#{key.capitalize()} #{value}." for key, value of response.data)
            .join ' '
          $scope.processingProject = false
        else
          $scope.projectCreateError = response.data.message.capitalize
          $scope.processingProject = false
      project.$save success, failure



