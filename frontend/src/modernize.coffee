$.getScript('polyfills/flexie.js') if not Modernizr.flexbox

if not Modernizr.input.required
  $.getScript('polyfills/jquery.h5validate.js').done ->
    $(document).ready ->
      $('form').h5Validate()

if not (Modernizr.input.placeholder and Modernizr.input.autofocus)
  $.getScript('polyfills/jquery.html5support.js').done ->
    $(document).ready ->
      $.placeholder() if not Modernizr.input.placeholder
      $.autofocus() if not Modernizr.input.autofocus


if  not (Modernizr.csstransforms and Modernizr.csstransforms3d)
  $.getScript('polyfills/transform/sylvester.js').done ->
    $.getScript('polyfills/transform/transformie.js')

if not Modernizr.testProp 'pointerEvents'
  $.getScript('polyfills/pointer_events_polyfill.js').done ->
    $(document).ready ->
      PointerEventsPolyfill.initialize {}