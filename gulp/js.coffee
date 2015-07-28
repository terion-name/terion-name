gulp = require 'gulp'

gulp.task 'js', ->
  uglify = require('gulp-uglify')

  gulp.src 'src/js/**/*'
  .pipe uglify()
  .pipe gulp.dest 'build/js'