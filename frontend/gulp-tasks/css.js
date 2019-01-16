var gulp = require('gulp');
var sass = require('gulp-sass');
var postcss = require('gulp-postcss');
var autoprefixer = require('autoprefixer');
var concatCss = require('gulp-concat-css');
var gulpMinCss = require('gulp-cssnano');
var order = require('gulp-order');
var merge = require('merge2');



function processSass() {
  var compiledSass = gulp.src('src/style/main.scss')
    .pipe(sass());
  var libCss = gulp.src('libs/**/*.css');
  return merge(libCss, compiledSass)
    .pipe(postcss([autoprefixer({browsers: ['last 5 version']})]))
    .pipe(concatCss('main.css', {
      rebaseUrls: false,
      inlineImports: false
    }));
}


function minifyCss(src) {
  return src.pipe(gulpMinCss({
    keepSpecialComments: 0,
    rebase: false,
    zindex: false,
    autoprefixer: false
  }));
}


exports.minifyCss = minifyCss;
exports.processSass = processSass;