angular.module 'evaluator'
  .directive 'course', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/course.html'
      scope:
        course: '=data'