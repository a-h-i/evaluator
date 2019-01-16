angular.module 'evaluator'
  .directive 'result', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/result.html'
      scope:
        result: '=data'