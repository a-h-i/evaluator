var gulp = require('gulp');

function processPolyfills() {
  return gulp.src('polyfills/**/*', {base: '.'});
}


exports.processPolyfills = processPolyfills;