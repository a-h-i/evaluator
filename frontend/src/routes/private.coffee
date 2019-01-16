angular.module 'evaluator'
  .config ($stateProvider) ->

    privateState =
      name: 'private'
      templateUrl: 'private/root.html'
      url: ''
      abstract: true
      data:
        authRule: (userAuth) ->
          if userAuth.signedIn
            {
              allowed: true
            }
          else
            {
              to: 'public.login'
              params: {}
              allowed: false
            }

    coursesState =
      name: 'private.courses'
      url: '/courses'
      resolve:
        $title: ->
          'Evaluator| Courses'
      views:
        'pageContent':
          templateUrl: 'private/courses.html'
          controller: 'CoursesController'

    courseState =
      name: 'private.course'
      url: '/course/:id'
      views:
        'pageContent':
          templateUrl: 'private/course.html'
          controller: 'CourseController'

    projectState =
      name: 'private.project'
      url: '/project/:id'
      views:
        'pageContent':
          templateUrl: 'private/project.html'
          controller: 'ProjectController'

    submissionsState =
      name: 'private.submissions'
      url: '/project/:project_id/submissions'
      views:
        'pageContent':
          templateUrl: 'private/submissions.html'
          controller: 'SubmissionsController'

    aboutState =
      name: 'private.about'
      url: '/evaluator'
      views:
        'pageContent':
          templateUrl: 'public/about.html'
      resolve:
        $title: ->
          'Evaluator| About'

    internalErrorState =
      name: 'private.internal_error'
      url: '/ooops'
      views:
        'pageContent':
          templateUrl: 'public/internal_error.html'
      resolve:
        $title: ->
          'Oopsy'

    profileState =
      name: 'private.profile'
      url: '/profile'
      views:
        'pageContent':
          templateUrl: 'private/profile.html'
          controller: 'ProfileController'
      resolve:
        $title: ->
          'Evaluator| Profile'

    unpublishedState =
      name: 'private.unpublished'
      url: '/unpublished'
      views:
        'pageContent':
          templateUrl: 'private/unpublished.html'

    teacherState =
      name: 'private.teacher'
      url: '/teacher'
      abstract: true
      data:
        authRule: (userAuth) ->
          if userAuth.signedIn && userAuth.user.teacher
            {
              allowed: true
            }
          else
            {
              to: 'private.courses'
              params: {}
              allowed: false
            }


    teacherPortal =
      name: 'private.teacher.portal'
      url: '/portal'
      views:
        'pageContent@private':
          templateUrl: 'private/teacher/portal.html'
          controller: 'PortalController'
      resolve:
        $title: ->
          'Evaluator| Teacher Portal'

    bundleDownload =
      name: 'private.teacher.bundle'
      url: '/bundle/:id'
      views:
        'pageContent@private':
          templateUrl: 'private/teacher/bundle_download.html'
          controller: 'BundleDownloadController'

    contactState =
      name: 'private.contact'
      url: '/feedback'
      views:
        'pageContent':
          templateUrl: 'public/contact.html'
          controller: 'ContactController'
      resolve:
        $title: ->
          'Evaluator| Feedback'

    thanksFeedbackState =
      name: 'private.thanks_feedback'
      url: '/thankyou'
      views:
        'pageContent':
          templateUrl: 'public/thanks_feedback.html'
      resolve:
        $title: ->
          'Thanks'

    bundlesState =
      name: 'private.teacher.bundles'
      url: '/bundles'
      views:
        'pageContent@private':
          templateUrl: 'private/teacher/bundles.html'
          controller: 'BundlesController'
      resolve:
        $title: ->
          'Paperwork'

    usersState =
      name: 'private.teacher.users'
      url: '/users'
      views:
        'pageContent@private':
          templateUrl: 'private/teacher/users.html'
          controller: 'UsersController'
      resolve:
        $title: ->
          'Evaluator| Users'

    userState =
      name: 'private.teacher.user'
      url: '/users/:id'
      views:
        'pageContent@private':
          templateUrl: 'private/teacher/user.html'
          controller: 'UserController'

    resultsState =
      name: 'private.teacher.results'
      url: '/results'
      views:
        'pageContent@private':
          templateUrl: 'private/teacher/results.html'
          controller: 'TeacherResultsController'
      resolve:
        $title: ->
          'Evaluator| Results'

    $stateProvider
      .state privateState
      .state coursesState
      .state courseState
      .state projectState
      .state submissionsState
      .state aboutState
      .state internalErrorState
      .state profileState
      .state unpublishedState
      .state teacherState
      .state teacherPortal
      .state bundleDownload
      .state contactState
      .state thanksFeedbackState
      .state bundlesState
      .state usersState
      .state userState
      .state resultsState
