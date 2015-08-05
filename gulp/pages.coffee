gulp = require 'gulp'
fs = require 'fs'

gulp.task 'pages', ->

  jade = require('gulp-jade')
  rename = require("gulp-rename")

  portfolio = JSON.parse(fs.readFileSync('src/data/portfolio.json', 'utf-8').toString())

  # build single-page
  gulp.src 'src/jade/pages/index.jade'
  .pipe jade {basedir: 'src/jade', locals: {portfolio: portfolio}}
  .pipe rename (path)->
    path.extname = ".html"
  .pipe gulp.dest 'build'

  #build statics

  gulp.src ['src/jade/pages/home.jade', 'src/jade/pages/about.jade']
  .pipe jade {basedir: 'src/jade', locals: {portfolio: portfolio}}
  .pipe rename (path)->
    path.basename = path.basename + "/index"
    path.extname = ".html"
  .pipe gulp.dest 'build'
  

  for work in portfolio
    do (work)->
      console.log "generation of " + work.alias
      gulp.src 'src/jade/pages/portfolio.work.jade'
      .pipe jade {basedir: 'src/jade', locals: work}
      .pipe rename (path)->
        path.extname = ".html"
        path.basename = work.alias + "/index"
      .pipe gulp.dest 'build/portfolio'
  

  gulp.src 'src/jade/pages/portfolio.jade'
  .pipe jade {basedir: 'src/jade', locals: {portfolio: portfolio}}
  .pipe rename (path)->
    path.basename = path.basename + "/index"
    path.extname = ".html"
  .pipe gulp.dest 'build'
  