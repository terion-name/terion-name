gulp = require 'gulp'

gulp.task 'img', ->
  imagemin = require 'gulp-imagemin'
  pngquant = require 'imagemin-pngquant'

  gulp.src 'src/img/**/*'
  .pipe(imagemin({
      progressive: true,
      svgoPlugins: [{removeViewBox: false}],
      use: [pngquant()]
    }))
  .pipe gulp.dest 'build/img'