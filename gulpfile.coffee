gulp = require 'gulp'
requireDir = require('require-dir')
tasks = requireDir('./gulp')

gulp.task 'default', ['pages', 'fonts', 'img', 'sass', 'js', 'coffee']

gulp.task 'watch', ->
  gulp.watch 'src/sass/**/*.sass', ['sass']
  gulp.watch ['src/jade/**/*.jade'], ['pages']
  gulp.watch 'src/coffee/**/*.coffee', ['coffee']

gulp.task 'sw', ['serve', 'watch']