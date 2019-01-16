angular.module 'evaluator'
  .directive 'project', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/project.html'
      scope:
        project: '=data'