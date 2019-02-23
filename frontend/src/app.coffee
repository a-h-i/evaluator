
angular.module 'evaluator', ['ngResource', 'ui.router', 'ui.router.title',
  'evaluatorTemplates', 'satellizer', 'LocalStorageModule', 'ngAnimate',
  'angulartics', 'angulartics.google.analytics', 'infinite-scroll',
  'ngFileUpload', 'ngFileSaver', 'ngMaterial', 'ngMessages', 'ngAria'
  ]



# Configuration blocks.

angular.module 'evaluator'
  .config ($compileProvider) ->
    $compileProvider.debugInfoEnabled false

angular.module 'evaluator'
  .config (localStorageServiceProvider) ->
    localStorageServiceProvider.setPrefix('evaluator')

angular.module 'evaluator'
  .config ($urlMatcherFactoryProvider) ->
    $urlMatcherFactoryProvider.strictMode false

# Defines constants for use within our app.
angular.module 'evaluator'
  .constant 'apiHost', '/api'
  .constant 'baseHost', '/'
  .constant 'defaultPageSize', 15
  .constant 'GUC_ID_REGEX', /^([0-9]+)-([0-9]+)$/
  .constant 'RECAPTCHA_KEY', '6LetW5MUAAAAAHYqwbTCL2RkMLOLfqPr901s90z1'

# Infinite scroll throttling
angular.module 'infinite-scroll'
  .value 'THROTTLE_MILLISECONDS', 250

angular.module 'evaluator'
  .run ($rootScope) ->
    $rootScope.$on '$viewContentLoaded', ->
      window.scroll 0, 0

    contentOffsetHandler = ->
      wrap = $ '#pageWrap'
      content = $ '.content'
      if wrap.hasClass 'open'
        y = window.scrollY
        xoffset = Math.tan(35 * Math.PI / 180) * y
        content.css('left', "-#{xoffset}px")
      else
        content.css('left', '0')
      return

    $(window).scroll contentOffsetHandler
    $rootScope.$on 'toggled', contentOffsetHandler
