angular.module 'evaluator'
  .directive 'highlight', ($timeout) ->
    directive =
      restrict: 'A'
      link: (scope, element) ->
        $timeout ->
          element.highlight('error', {className: 'bold-weight error'})
