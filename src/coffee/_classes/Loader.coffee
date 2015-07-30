class Loader

  constructor: (@container)->
    @generate()

  generate: ->
    w = document.createElement('div')
    w.className = 'loader_widget'
    o = new Image
    o.className = 'outer'
    o.src = '/img/loader_outer.svg'
    i = new Image
    i.className = 'inner'
    i.src = '/img/loader_inner.svg'
    
    w.appendChild o
    w.appendChild i
    
    @loader = w
    
  start: (prepend)->
    addClass @container, 'loading'
    if prepend
      @container.prependChild @loader
    else
      @container.appendChild @loader
      
  stop: ->
    @container.removeChild @loader
    removeClass @container, 'loading'
    