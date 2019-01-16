angular.module 'evaluator'
  .factory 'redirect', ->
    class Redirect
      constructor: (@history=[]) ->

      push: (data) ->
        @history.push data

      pop: ->
        @history.pop()

      @property 'empty',
        get: ->
          @history.length == 0

    return new Redirect