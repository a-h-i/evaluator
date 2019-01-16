# Prototype extensions for built in objects
angular.module 'evaluator'
  .config ->
    if typeof Array::remove isnt 'function'
      Array::remove = (element) ->
        index = @indexOf element
        if index > -1
          @splice index, 1
          return true
        else
          return false
    Object.defineProperty Array::, 'size', {
      get: ->
        @length
    }

angular.module 'evaluator'
  .config ->
    String::capitalize = ->
      return @charAt(0).toUpperCase() + @slice(1).toLowerCase()

angular.module 'evaluator'
  .config ->
    Function::property = (prop, desc) ->
      Object.defineProperty @::, prop, desc
