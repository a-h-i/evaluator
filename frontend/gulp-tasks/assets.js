var gulp = require('gulp');

function processAssets() {
  return gulp.src(['images/**/*', 'fonts/**/*'], {base: '.'});
}


exports.processAssets = processAssets;