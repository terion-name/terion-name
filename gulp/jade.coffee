gulp = require 'gulp'

gulp.task 'jade', ->

  jade = require('gulp-jade')
  rename = require("gulp-rename")

  #gulp.src 'src/jade/*.jade'
  #  .pipe jade {basedir: 'src/base/jade'}
  #  .pipe extReplace '.html'
  #  .pipe rename (path)->
  #      unless path.basename == 'index'
  #        path.dirname += "/" + path.basename
  #        path.basename = "index"
  #      path.extname = ".html"
  #  .pipe gulp.dest 'build'