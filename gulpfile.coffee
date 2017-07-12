# Gulp stuff.
gulp = require('gulp')
clean = require('gulp-clean')
gutil = require('gulp-util')
coffee = require('gulp-coffee')
sourcemaps = require('gulp-sourcemaps')
touch = require('touch')
path = require('path')
tap = require('gulp-tap')
parallelize = require("concurrent-transform")

threads = 100

coffeeFiles = ['docco.litcoffee', 'src/**/*.litcoffee', 'test/unit-tests/**/*.litcoffee']

javascriptFiles = ['docco.js', 'docco.js.map', 'src/**/*.js', 'src/**/*.js.map', 'test/unit-tests/**/*.js', 'test/unit-tests/**/*.js.map']

gulp.task('touch', () ->
  gulp.src(coffeeFiles)
    .pipe(tap((file, t) ->
      touch(file.path)
    )
  )
)

gulp.task('coffeescripts', () ->
  gulp.src(coffeeFiles)
    .pipe(sourcemaps.init())
    .pipe(parallelize(coffee({bare: true}).on('error', gutil.log), threads))
    .pipe(parallelize(sourcemaps.write('./'), threads))
    .pipe(parallelize(gulp.dest((file) -> return file.base), threads))
)

gulp.task('watch', () ->
  gulp.watch(coffeeFiles, ['compile-and-test'])
)

gulp.task('clean', () ->
  return gulp.src(javascriptFiles, {read: false})
    .pipe(clean())
)

gulp.task('build', ['coffeescripts']) # ,'jadescripts','stylusscripts'])

gulp.task('default', ['watch', 'coffeescripts'])

gulp.task('done', (() -> ))