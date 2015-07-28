gulp = require 'gulp'

gulp.task 'coffee', ->
  include = require 'gulp-include'
  uglify = require('gulp-uglify')
  coffee = require "gulp-coffee"

  gulp.src 'src/coffee/*.coffee'
  .pipe include()
  .pipe coffee()
  .pipe uglify()
  .on 'error', (e)-> console.error e
  .pipe gulp.dest 'build/js'