class WorkController

  constructor: (@container)->
    @container.controller = this
    @transitionDuration = 300
    @animating = false
    @gallery = @container.getElementsByClassName('gallery')[0]
    @slides = @gallery.getElementsByClassName('slide')
    @buttonRight = @gallery.getElementsByClassName('right')[0]
    @buttonLeft = @gallery.getElementsByClassName('left')[0]
    @desc = @container.getElementsByClassName('desc')[0]
    @descHider = @desc.getElementsByClassName('hide')[0]
    @back = @container.getElementsByClassName('back')[0]

    @init()
    @bind()

  init: ->
    for slide in @slides
      slide.style.display = 'none'
      loader = new Loader slide
      slide.loader = loader
      loader.start()
      
    @slides[0].style.display = ''
    @currentSlide = 0

    if @slides.length == 1
      @buttonRight.style.display = 'none'
      @buttonLeft.style.display = 'none'


  bind: ->
    @back.addEventListener 'click', (e)=>
      if document.getElementById('portfolio')
        return if @animating
        e.preventDefault()
        @disappear()
        window.history?.pushState({index: 1}, '', "/portfolio")

    @buttonRight.addEventListener 'click', (e)=>
      return if @animating
      @galleryNext()
    @buttonLeft.addEventListener 'click', (e)=>
      return if @animating
      @galleryPrev()

    @descHider.addEventListener 'click', (e)=>
      if hasClass(@desc, 'hidden')
        removeClass(@desc, 'hidden')
      else
        addClass(@desc, 'hidden')
        removeClass(@desc, 'hidden-temp')

  appear: (callback)->
    @animStarted()
    removeClass @desc, 'hidden'
    Velocity @desc, {
      translateZ: 0
      translateY: [0, '100%']
    }, {
      duration: @transitionDuration
      easing: 'easeOutQuad'
      display: 'block'
      complete: =>
        @desc.style.transform = @desc.style.WebkitTransform = ''
        removeClass @gallery, 'hidden'
        Velocity @gallery, {
          translateZ: 0
          translateY: [0, '-100%']
        }, {
          duration: @transitionDuration
          easing: 'easeOutQuad'
          display: 'block'
          complete: =>
            @gallery.style.transform = @gallery.style.WebkitTransform = ''
            setTimeout (=>
              @loadSlide @slides[@currentSlide]
              addClass @desc, 'anim'
              @animEnded()
              callback(this) if callback
            ), 25
          }
    }
    

  disappear: ->
    @animStarted()
    removeClass @desc, 'anim'
    Velocity @gallery, {
        translateZ: 0
        translateY: ['-100%', 0]
      },
      duration: @transitionDuration
      easing: 'easeOutQuad'
      display: 'none'
      complete: =>
        Velocity @desc, {
          translateZ: 0
          translateY: ['100%', 0]
        },
          duration: @transitionDuration
          easing: 'easeOutQuad'
          display: 'none'
          complete: =>
            @container.parentNode.removeChild @container
            @animEnded()

  galleryNext: ->
    return if @animating
    nextSlide = @currentSlide + 1
    nextSlide = 0 if nextSlide >= @slides.length
    @galleryMove nextSlide

  galleryPrev: ->
    return if @animating
    nextSlide = @currentSlide - 1
    nextSlide = @slides.length - 1 if nextSlide < 0
    @galleryMove nextSlide, true

  galleryMove: (slide, toLeft)->
    cur = @slides[@currentSlide]
    next = @slides[slide]

    cur.pause() if cur.player?
    
    @animStarted()
    
    # let this be for future experiments
    # at the moment css animations are too unreliable
    cssAnim = false
    
    if cssAnim
      removeClass cur, 'animated_out'
      removeClass cur, 'animated_in'
      cur.style.left = 0
      cur.style.transform = "scale(1) translateZ(0)"
      cur.style.WebkitTransform = "scale(1) translateZ(0)"
  
      setTimeout (=>
        addClass cur, 'animated_out'
        once cur, window._transitionEndEventName, (e)=> cur.style.display = "none"
        cur.style.transform = "scale(0.8) translateZ(0)"
        cur.style.WebkitTransform = "scale(0.8) translateZ(0)"
        cur.style.left = "#{if toLeft then '' else '-'}100%"
      ), 25
  
      removeClass next, 'animated_in'
      removeClass next, 'animated_out'
      next.style.left = "#{if toLeft then '-' else ''}100%"
      next.style.transform = "scale(0.8) translateZ(0)"
      next.style.WebkitTransform = "scale(0.8) translateZ(0)"
      next.style.display = "block"
      
      setTimeout (=>
        addClass next, 'animated_in'
        once next, window._transitionEndEventName, (e)=> 
          @animEnded()
          @loadSlide next
        next.style.left = 0
        next.style.transform = "scale(1) translateZ(0)"
        next.style.WebkitTransform = "scale(1) translateZ(0)"
      ), 25

    else
      Velocity cur, { translateZ: 0, translateX: ["#{if toLeft then '' else '-'}100%", 'easeOutQuad', 0], scale: [0.8, 'easeOutExpo', 1] }, {
        duration: @transitionDuration * 2, complete: -> 
          cur.setAttribute 'style', ''
          cur.style.display = 'none'
      }
      Velocity next, { translateZ: 0, translateX: [0, 'easeOutQuad', "#{if toLeft then '-' else ''}100%"], scale: [1, 'easeInExpo', 0.8] }, {
        duration: @transitionDuration * 2, display: 'block', complete: =>
          next.setAttribute 'style', ''
          @animEnded()
          @loadSlide next
      }
    @currentSlide = slide

  loadSlide: (slide)->
    
    if hasClass slide, 'video'
      unless hasClass @desc, 'hidden'
        addClass @desc, 'hidden'
        addClass @desc, 'hidden-temp'
    else if hasClass @desc, 'hidden-temp'
      removeClass @desc, 'hidden'
      removeClass @desc, 'hidden-temp'

    return if slide.loaded
    
    if hasClass slide, 'image' 
        imageSrc = slide.getAttribute('data-image')
        img = new Image
        img.onload = ((slide)->->
          slide.loader?.stop()
          slide.style.backgroundImage = "url('#{this.src}')"
        )(slide)
        img.src = imageSrc
        slide.loaded = true
    else if hasClass slide, 'video'
      videoSrc = slide.getAttribute('data-src')
      parser = document.createElement 'a'
      parser.href = videoSrc
      if videoSrc.search('vimeo') > 0
        videoId = trim parser.pathname, '/'
        @loadVideoVimeo videoId, slide
      else
        query = trim parser.search, '?'
        params = getQueryParams query
        videoId = params.v
        @loadVideoYoutube videoId, slide

  loadVideoYoutube: (videoId, slide)->
    render = ->
      slide.innerHTML = '<div class="video_iframe"></div>'
      player = new YT.Player(slide.getElementsByClassName('video_iframe')[0], {
        height: '100%',
        width: '100%',
        videoId: videoId,
        rel: 0,
        events:
          onReady: ->
            slide.loaded = true
            slide.loader?.stop()
      })
      slide.player = player
      slide.pause = -> slide.player.pauseVideo()
      
    unless YT?
      p = if /^http:/.test(window.location) then 'http' else 'https'
      tag = document.createElement('script')
      tag.src = p + "://www.youtube.com/iframe_api"
      firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
      window.onYouTubeIframeAPIReady = -> 
        render()
    else
      render()
      
  loadVideoVimeo: (videoId, slide)->
    render = ->
      iframeSrc = "https://player.vimeo.com/video/#{videoId}?color=ffffff&title=0&byline=0&portrait=0&api=1"
      iframe = document.createElement('iframe')
      iframe.className = 'video_iframe'
      iframe.src = iframeSrc
      iframe.frameBorder = 0
      iframe.setAttribute 'webkitAllowFullScreen', ''
      iframe.setAttribute 'mozAllowFullScreen', ''
      iframe.setAttribute 'allowFullScreen', ''
      slide.appendChild iframe
      player = Froogaloop iframe
      slide.player = player
      slide.pause = -> slide.player.api('pause')
      player.addEvent 'ready', ->
        slide.loader?.stop()
        slide.loaded = true
        
    unless Froogaloop?
      p = if /^http:/.test(window.location) then 'http' else 'https'
      tag = document.createElement('script')
      tag.onload = -> render()
      tag.src = p + "://f.vimeocdn.com/js/froogaloop2.min.js"
      firstScriptTag = document.getElementsByTagName('script')[0]
      firstScriptTag.parentNode.insertBefore(tag, firstScriptTag)
    else
      render()
    
      
  animStarted: ->
    @animating = true
    addClass document.body, 'disable-hover'

  animEnded: ->
    @animating = false
    removeClass document.body, 'disable-hover'