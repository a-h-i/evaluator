angular.module 'evaluator'
  .directive 'clickRemove', ->
    directive =
      restrict: 'A'
      link: (scope, element, attrs) ->
        element.click ->
          target = element
          if attrs.clickRemoveTarget
            target = $ attrs.clickRemoveTarget
          target.removeClass attrs.clickRemove
          scope.$emit 'removed'
          scope.$apply()
          return false if attrs.preventDefault
