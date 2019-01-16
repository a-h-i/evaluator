angular.module 'evaluator'
  .directive 'gucEmail', ->
    GUC_EMAIL_REGEX = /^[a-zA-Z\.\-]+@(student.)?guc.edu.eg$/
    directive =
      require: 'ngModel'
      restrict: 'A'
      link: (scope, element, attrs, ctrl) ->
        ctrl.$validators.guc_email = (modelValue, viewValue) ->
          if ctrl.$isEmpty modelValue
            return true

          return GUC_EMAIL_REGEX.test viewValue