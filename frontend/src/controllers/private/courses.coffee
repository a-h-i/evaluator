angular.module 'evaluator'
  .controller 'CoursesController', ($scope, $state, Pagination,
    $mdDialog, CoursesResource, UserAuth, defaultPageSize, Course,
    NotificationDispatcher, configurations) ->
      $scope.courses = []
      ids = []

      $scope.courseClasses = ['course-accent-one', 'course-accent-two',
      'course-accent-three']

      $scope.scrollDisabled = false
      $scope.loading = true
      $scope.newCourseData = {}
      $scope.courseCreateError = ''

      $scope.canAddCourses = UserAuth.user.teacher && UserAuth.user.admin
      $scope.isTeacher = UserAuth.user.teacher
      $scope.isAdmin = UserAuth.user.admin

      publishedCourseCallback = (course) ->
        if not $scope.isTeacher
          $scope.addCoursesCallback [course], 0


      deletedCourseCallback = (courseID) ->
        _.remove ids, (id) ->
          id is courseID
        _.remove $scope.courses, (course) ->
          course.id is courseID

      unpublishedCourseCallback = (courseID) ->
        if not $scope.isTeacher
          deletedCourseCallback courseID

      courseFactory = (data) ->
        new Course(new CoursesResource(data), angular.noop, angular.noop,
          publishedCourseCallback, unpublishedCourseCallback,
          deletedCourseCallback
        )

      coursesPagination = new Pagination CoursesResource, 'courses', {},
        courseFactory, defaultPageSize


      # Add courses to $scope.courses at begin (index)
      addCoursesCallback = (newCourses, begin) ->
        courses = _.filter newCourses, (course) ->
          course.id not in ids
        Array::push.apply ids, _.map courses, 'id'
        args = [begin, 0].concat courses
        $scope.courses.splice.apply $scope.courses, args

      $scope.addCoursesCallback = addCoursesCallback

      NotificationDispatcher.subscribeCourses (e) ->
        configurations.then (config) ->
          if e.type is config.notification_event_types.course_created
            course = courseFactory e.payload.course
            addCoursesCallback([course], 0) if $scope.isTeacher or
              course.published
          else if e.type is config.notification_event_types.course_published
            course = courseFactory e.payload.course
            addCoursesCallback([course], 0)



      # Load first page
      coursesPagination.page(1).then (data) ->
        $scope.loading = false
        addCoursesCallback data, $scope.courses.length

      # Callback for infinite scroll
      $scope.loadMore = ->
        $scope.scrollDisabled = true
        page = if coursesPagination.hasPages() then \
          coursesPagination.currentPage + 1 else coursesPagination.currentPage
        coursesPagination.page(page)
          .then (courses) ->
            addCoursesCallback courses, $scope.courses.length
            $scope.scrollDisabled = false

      $scope.showAddDialog = ($event) ->
        $scope.newCourseData = {}
        $scope.courseCreateError = ''

        $mdDialog.show
          targetEvent: $event
          clickOutsideToClose: true
          scope: $scope
          parent: angular.element(document.body)
          preserveScope: true
          templateUrl: 'private/create/course.html'

      $scope.submit = ->
        return if $scope.processingCourse
        $scope.processingCourse = true
        course = new CoursesResource $scope.newCourseData
        success = (data) ->
          $mdDialog.hide()
          $scope.processingCourse = false
          course = new Course data
          addCoursesCallback [course], $scope.courses.length
        failure = (response) ->
          if response.status is 422
            $scope.courseCreateError =
              ("#{key.split('_').join(' ').capitalize()} #{value}." for key, value of response.data)
              .join ' '
            $scope.processingCourse = false
          else
            $scope.courseCreateError = response.data.message.capitalize
            $scope.processingCourse = false
        course.$save success, failure
