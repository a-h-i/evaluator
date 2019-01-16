angular.module 'evaluator'
  .directive 'resultCase', ->
    directive =
      restrict: 'AE'
      templateUrl: 'directives/result_case.html'
      scope:
        case: '=data'