gulp = require 'gulp'

gulp.task 'pages', ->

  jade = require('gulp-jade')
  rename = require("gulp-rename")

  # build single-page
  gulp.src 'src/jade/pages/index.jade'
  .pipe jade {basedir: 'src/jade'}
  .pipe rename (path)->
    path.extname = ".html"
  .pipe gulp.dest 'build'

  gulp.src 'src/jade/pages/portfolio.work.jade'
  .pipe jade {basedir: 'src/jade'}
  .pipe rename (path)->
    path.extname = ".html"
    path.basename = "work"
  .pipe gulp.dest 'build'

