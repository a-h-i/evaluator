angular.module 'evaluator'
  .directive 'bundle', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/bundle.html'
      scope:
        bundle: '=data'