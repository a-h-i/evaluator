angular.module 'evaluator'
  .directive 'gucId', (GUC_ID_REGEX) ->
    directive =
      require: 'ngModel'
      restrict: 'A'
      link: ($scope, element, attrs, ctrl) ->
        ctrl.$validators.guc_id = (modelValue, viewValue) ->
          if ctrl.$isEmpty modelValue
            return true
          return GUC_ID_REGEX.test viewValue