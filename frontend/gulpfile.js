var gulp = require('gulp');
var fs = require('fs');
var gzip = require('gulp-gzip');
var merge = require('merge2');
var concat = require('gulp-concat');
var minimist = require('minimist');
var uglify = require("gulp-uglify");
var ngAnnotate = require('gulp-ng-annotate');
var minifyHtml = require('gulp-htmlmin');
var connect = require('gulp-connect');
var modRewrite = require('connect-modrewrite');
var bower = require('gulp-bower');
var mainBowerFiles = require('main-bower-files');
var css = require('./gulp-tasks/css');
var assets = require('./gulp-tasks/assets');
var polyfills = require('./gulp-tasks/polyfills');
var templates = require('./gulp-tasks/templates');
var scripts = require('./gulp-tasks/scripts');
var rimraf = require('rimraf');
var watch = require('gulp-watch');
var proxyMiddleware = require('http-proxy-middleware');


gulp.task('create-dirs', function(cb) {
  var dirs = ['build', 'dist', 'libs'];
  rimraf.sync('libs');
  dirs.forEach(function(dir) {
    try {
      fs.mkdirSync(dir);
    } catch(e) {
      if (e.code !== 'EEXIST') {
        throw e;
      }
    }
  });
  return cb();
});

gulp.task('bower-install', function() {
  // Runs bower install
  return bower()
    .pipe(gulp.dest('./bower_components'));
});

gulp.task('bower', gulp.series('create-dirs', 'bower-install', function() {
  // moves main files to lib folder
  return gulp.src(mainBowerFiles(), {base: 'bower_components'})
    .pipe(gulp.dest('libs'));
}));


gulp.task('build', gulp.series('bower', function() {
  var cssStream = css.processSass();
  var scriptStream = scripts.processScripts();
  var dependenciesStream = scripts.processDeps();
  var routesStream = scripts.processRoutes();
  var templatesStream = templates.processTemplates();
  var index = gulp.src('src/index.html');
  var assetsStream = assets.processAssets();
  var polyfillsStream = polyfills.processPolyfills();
  var js = merge(dependenciesStream, templatesStream, scriptStream, routesStream)
    .pipe(concat('app.js'));
  var streams = merge([cssStream, js, assetsStream, polyfillsStream, index]);
  return streams.pipe(gulp.dest('build'))
}));

gulp.task('default', gulp.series('build'));



var options = minimist(process.argv.slice(2), {
  string: 'dest',
  default: {dest: 'dist'}
})

gulp.task('production-helper', gulp.series('bower', function() {
  var cssStream = css.minifyCss(css.processSass());
  var scriptStream = scripts.processScripts().pipe(ngAnnotate()).pipe(uglify());
  var dependenciesStream = scripts.processDeps().pipe(uglify());
  var routesStream = scripts.processRoutes().pipe(uglify({mangle: false}));
  var templatesStream = templates.minifyTemplates();
  var assetsStream = assets.processAssets();
  var index = gulp.src('src/index.html').pipe(minifyHtml({
      empty: true
    }));
  var polyfillsStream = polyfills.processPolyfills();
  var js = merge(dependenciesStream, templatesStream, scriptStream, routesStream)
    .pipe(concat('app.js'));
  var streams = merge([cssStream, js, assetsStream, polyfillsStream, index]);
  return streams
    .pipe(gulp.dest(options.dest));
}));

gulp.task('production', gulp.series('production-helper', function () {
  var src = [options.dest, '**', '*.{html,css,js,eot,svg,ttf,otf,json}'].join('/');
  return gulp.src(src)
    .pipe(gzip({ gzipOptions: { level: 9 } }))
    .pipe(gulp.dest(options.dest));
}));


gulp.task('server', gulp.series('build', function() {
  var proxyOpts = {
    target: 'http://localhost:3000',
    ws: true
  }
  connect.server({
    livereload: true,
    root: 'build',
    port: 8000,
    middleware: function() {
      return [
        modRewrite([
          '^/api/(.*)$ http://localhost:3000/api/$1 [P]'
        ]),
        proxyMiddleware('/faye', proxyOpts)
      ];
    }
  });
}));

gulp.task('reload', gulp.series('build', function() {
  return gulp.src('./build/**/*')
    .pipe(connect.reload());
}));
gulp.task('watch', function() {
  watch(['src/**', 'images/**', 'assets/**', 'polyfills/**', 'fonts/**', 'bower.json'], function() {
    return gulp.src('./build/**/*')
    .pipe(connect.reload());
  });
});

gulp.task('dev', gulp.parallel('watch', 'server'));

