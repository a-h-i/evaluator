
import 'core-js/es/symbol';
import 'core-js/es/object';
import 'core-js/es/function';
import 'core-js/es/parse-int';
import 'core-js/es/parse-float';
import 'core-js/es/number';
import 'core-js/es/math';
import 'core-js/es/string';
import 'core-js/es/date';
import 'core-js/es/array';
import 'core-js/es/regexp';
import 'core-js/es/map';
import 'core-js/es/weak-map';
import 'core-js/es/set';
import 'core-js/proposals/reflect-metadata';
/** IE10 and IE11 requires the following for NgClass support on SVG elements */
import 'classlist.js'; // Run `npm install --save classlist.js`.
/** IE10 and IE11 requires the following for the Reflect API. */
import 'web-animations-js';
import 'zone.js/dist/zone';
import 'hammerjs';

if (process.env.IS_PRODUCTION) {
  // Production
} else {
  // Development and test
  Error['stackTraceLimit'] = Infinity;
  require('zone.js/dist/long-stack-trace-zone');
}