gulp = require 'gulp'

gulp.task 'fonts', ->

  gulp.src 'src/fonts/**/*'
    .pipe gulp.dest 'build/fonts'

  ###
  fontfacegen is too buggy...

  fontfacegen = require('fontfacegen')
  fs = require('fs')
  path = require('path')
  concat = require('concat-files')

  fonts = fs.readdirSync('src/fonts/')
  cssFiles = []
  for font in fonts
    extension = path.extname(font)
    fontname = path.basename(font, extension)
    if extension == '.ttf' or extension == '.otf'
      fontfacegen
        source:  path.join('src/fonts/', font),
        dest: 'build/fonts/',
        collate: true
        css: "build/fonts/#{fontname}.css"
        css_fontpath: "/"

      cssFiles.push "build/fonts/#{fontname}.css"

  concat cssFiles, 'build/fonts/fonts.css'

  ###