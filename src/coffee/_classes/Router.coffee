class Router

  constructor: (@container)->
    @screen = 0
    @transitionDuration = 500
    @animating = false
    @onScreenChange = null
    
    @body = document.body
    @screens = document.getElementsByClassName('screen')
    
    if @screens.length == 1
      @initSinglePage()
    else 
      @init()
      @bind()
      setTimeout (->window.appInit()), 0
    
  init: ->
    @container.style.overflow = 'hidden'
    @container.scrollTop = 0
    
  bind: ->
    @screens[0].addEventListener 'wheel', (e)=>
      return if @animating
      if e.deltaY > 0 and (@body.scrollTop >= @body.scrollHeight - window.innerHeight)
        @goto(1)
        
    window.addEventListener 'resize', => @adjustScreen()

    window.addEventListener 'popstate', ((e)=>
      if e.state
        @loadScreen e.state
      else
        @parsePath()
    ), false
      
        
  goto: (scr, transition, callback, noPopState)->
    return if @animating
    @animStarted()
    Velocity @screens[scr], 'scroll',
      container: @container
      duration: if transition? then transition else @transitionDuration * Math.abs(scr - @screen)
      easing: 'easeOutQuad'
      complete: =>
        setTimeout (=>
          @animEnded()
          callback(scr) if callback
          @screens[scr].controller?.setup?()
        ), 10
        
    if @screen != scr
      if scr > @screen
        @screens[scr].style.top = '-75%'
        shadowed = @screens[scr-1]
      else
        @screens[scr].style.top = '75%'
        shadowed = @screens[scr+1]
        
      @screens[scr].style.zIndex = 10
      shadowed.style.zIndex = 20

      Velocity shadowed, { boxShadowBlur: [0, 100], boxShadowSpread: [0, 25] },
        queue: false
        duration: if transition? then transition else @transitionDuration * Math.abs(scr - @screen)
        easing: 'easeInExpo'
      
      Velocity @screens[scr], { top: 0, scale: [1, 'easeInExpo', 0.95] },
        queue: false
        container: @container
        duration: if transition? then transition else @transitionDuration * Math.abs(scr - @screen)
        easing: 'easeOutQuad'
        complete: =>
          @screens[scr].style.zIndex = ''
          @screens[@screen].style.zIndex = ''

      @screen = scr
      @onScreenChange(scr) if @onScreenChange
      window.history?.pushState({index: scr}, '', "/#{@screens[scr].getAttribute('id')}") unless noPopState
      
    window.siteHeader.homeMode(scr == 0)
    
  loadScreen: (opts, transition, pushstate)->
    callback = null
    if opts.page
      scr = document.getElementById(opts.page)
      return if not scr or not hasClass scr, 'screen'
      index = 0
      for screen in @screens
        break if screen.getAttribute('id') == opts.page
        index++
      opts.index = index

    if opts and opts.work
      callback = =>
        document.getElementById('portfolio').getElementsByClassName('work_overlay')[0]?.controller.disappear()
        document.getElementById('portfolio').getElementsByClassName('item')[0].controller.loadWork(true, opts.work)
    else if opts and opts.index == 1 and not opts.work
      callback = =>
        document.getElementById('portfolio').getElementsByClassName('work_overlay')[0]?.controller.disappear()

    @goto (if opts then opts.index else 0), transition, callback, !pushstate


  initSinglePage: ->
    promise.get('/').then (error, text, xhr)=>
      #console.log text
      if (error)
        console.error error
        #TODO handle error
      else
        parser = new DOMParser()
        doc = parser.parseFromString(text, "text/html")
        document.getElementById('container').innerHTML = doc.getElementById('container').innerHTML
        @init()
        @bind()
        window.appInit()
        @parsePath()
        
  parsePath: ->
    path = trim window.location.pathname, '/'
    path = path.split('/')
    opts = {}
    opts.page = path[0] or 'home'
    if path[0] == 'portfolio' and path[1]?
      opts.work = '/portfolio/' + path[1]
    @loadScreen opts, 0
    
    
  adjustScreen: (transition)->
    if transition
      @goto @screen, transition
    else
      @container.scrollTop = @screen * @container.offsetHeight
    
  animStarted: ->
    @animating = true
    addClass document.body, 'disable-hover'

  animEnded: ->
    @animating = false
    removeClass document.body, 'disable-hover'