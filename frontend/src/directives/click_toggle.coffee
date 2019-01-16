###
Toggles a set of classes on an element.
  If clickToggleTarget attribute is present the classes will be toggled on it.
  Otherwise they will be targeted on the directive's element.
  if preventDefault  attribute is a truthy value (present) the event handler
  will return false.
###
angular.module 'evaluator'
  .directive 'clickToggle', () ->
    directive =
      restrict: 'A'
      link: (scope, element, attrs) ->
        element.click ->
          target = element
          if attrs.clickToggleTarget
            target = $ attrs.clickToggleTarget
          target.toggleClass attrs.clickToggle
          scope.$emit 'toggled'
          scope.$apply()
          return false if attrs.preventDefault