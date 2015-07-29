gulp = require 'gulp'

gulp.task 'sass', ->

  compass = require 'gulp-compass'
  csso = require 'gulp-csso'
  autoprefixer = require "gulp-autoprefixer"

  gulp.src ['src/sass/*.sass', '!src/sass/_*', '!src/sass/_*/*']
  .pipe compass
  #project: '',
    css: 'build/css/'
    sass: 'src/sass/'
    image: 'src/img/'
    require: ['bootstrap-sass', 'sass-globbing', 'compass-normalize']
    comments: false
    style: 'expanded'
    bundle_exec: true
  .on 'error', (e)-> console.error e
  .pipe autoprefixer browsers: ['last 2 version', 'safari 5', 'ie 9', 'opera 12.1', 'ios 6', 'android 4'], remove: false
  .pipe csso()
  .pipe gulp.dest 'build/css'
