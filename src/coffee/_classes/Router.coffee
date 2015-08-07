class Router

  constructor: (@container)->
    @screen = 0
    @transitionDuration = 500
    @animating = false
    @onScreenChange = null
    
    @body = document.body
    @html = document.getElementsByTagName('html')[0]
    @screens = document.getElementsByClassName('screen')
    
    # this is used to overcome mac os inertia issues during navigation 
    @screenChangeTime = new Date()
    @lastScroll = new Date()
    
    if @screens.length == 1
      @initSinglePage()
    else 
      @init()
      @bind()
      setTimeout (->window.appInit()), 0
    
  init: ->
    @container.style.overflow = 'hidden'
    @container.scrollTop = 0
    addClass @container, 'js-inited'
    for scr in @screens
      scr.style.display = 'none'
    @screens[@screen].style.display = 'block'

      
  bind: ->        
    for sceen, index in @screens
      sceen.addEventListener 'wheel', ((index)=>(e)=>
        thisScroll = new Date()
        inertia = (thisScroll - @screenChangeTime < 300) or (thisScroll - @lastScroll < 60)
        @lastScroll = thisScroll
        # normalize firefox
        globalScroll = @body.scrollTop or @html.scrollTop
        return if @animating
        unless inertia
          if e.deltaY > 0 and (globalScroll >= @body.scrollHeight - window.innerHeight)
            if index < @screens.length - 1 then @loadScreen({index: index+1}, null, true)
          else if e.deltaY < 0 and (@body.scrollTop == 0)
            if index > 0 then @loadScreen({index: index-1}, null, true))(index)

    window.addEventListener 'wheel', (e)=>
      unless @body.scrollHeight - window.innerHeight > 0
        e.preventDefault()
      
    window.addEventListener 'popstate', ((e)=>
      if e.state
        @loadScreen e.state
      else
        @parsePath()
    ), false
      
        
  goto: (scr, transition, callback, noPopState)->
    return if @animating
    @animStarted() unless transition == 0

    if @screen != scr
      targetScreen = @screens[scr]
      currentScreen = @screens[@screen]

      currentScreen.style.zIndex = 20
      targetScreen.style.zIndex = 10

      if scr < @screen
        targetScreenAnim = { translateZ: 0, translateY: [0, 'easeOutQuad', '-25%'], scale: [1, 'easeInExpo', 0.9] }
        currentScreenAnim =
          translateZ: 0
          translateY: ['100%', 'easeOutQuad', 0]
          # box-shadow ruins fps in webkit...
          #boxShadowBlur: [0, 'easeInExpo', 100]
          #boxShadowSpread: [0, 'easeInExpo', 25]
      else
        targetScreenAnim = { translateZ: 0, translateY: [0, 'easeOutQuad', '25%'], scale: [1, 'easeInExpo', 0.9] }
        currentScreenAnim =
          translateZ: 0
          translateY: ['-100%', 'easeOutQuad', 0]
          # box-shadow ruins fps in webkit...
          #boxShadowBlur: [0, 'easeInExpo', 100]
          #boxShadowSpread: [0, 'easeInExpo', 25]
          
      Velocity currentScreen, currentScreenAnim,
        queue: false
        duration: if transition? then transition else @transitionDuration
        display: 'none'
          
      Velocity targetScreen, targetScreenAnim,
        queue: false
        duration: if transition? then transition else @transitionDuration
        display: 'block'
        complete: =>
          setTimeout (=>
            targetScreen.controller?.setup?()
            callback(scr) if callback
            @onScreenChange(scr) if @onScreenChange
            currentScreen.controller?.unload?()
            
            # firefox on mac behave very strange with inertia.. this is a workaround
            @screenChangeTime = new Date()
            
            @animEnded()
          ), 10
      @screen = scr
    else
      callback(scr) if callback
      @animEnded()
      
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
    
    
  animStarted: ->
    @animating = true
    addClass document.body, 'disable-hover'

  animEnded: ->
    @animating = false
    removeClass document.body, 'disable-hover'