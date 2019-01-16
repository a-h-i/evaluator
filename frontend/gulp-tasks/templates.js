var gulp = require('gulp');
var concat = require('gulp-concat');
var templateCache = require('gulp-angular-templatecache');
var minifyHtml = require('gulp-htmlmin');

function createModule(src) {
  return src.pipe(templateCache('templates.js', {
      standalone: true,
      module: 'evaluatorTemplates',
      transformUrl: function(url) {
        if(url[0] == '/') {
          return url.substring(1);
        } else {
          return url;
        }
      }
    }));
}

function processTemplates() {
  var src = gulp.src('src/views/**/*.html');
  return createModule(src);
}

function minifyTemplates() {
  var src = gulp.src('src/views/**/*.html')
  .pipe(minifyHtml({
    empty: true
  }));
  return createModule(src);
}



exports.processTemplates = processTemplates;
exports.minifyTemplates = minifyTemplates;