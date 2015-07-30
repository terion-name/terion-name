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

    @loadSlide @slides[@currentSlide]

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


  appear: (callback)->
    @gallery.style.top = '-100%'

    @animStarted()
    Velocity @desc, {
      translateY: [0, '100%']
    }, {
      duration: @transitionDuration
      easing: 'easeOutQuad'
      complete: =>
        Velocity @gallery, {top: 0}, {duration: @transitionDuration, easing: 'easeOutQuad', complete: => 
          @animEnded()
          callback(this) if callback
        }
    }

  disappear: ->
    @animStarted()
    Velocity @desc, {
      translateY: '100%'
    }, {
      duration: @transitionDuration
      easing: 'easeOutQuad'
      complete: =>
        Velocity @gallery, {
          top: '-100%'
        }, {
          duration: @transitionDuration
          easing: 'easeOutQuad'
          complete: =>
            @container.parentNode.removeChild @container
            @animEnded()
        }
    }

  galleryNext: ->
    return if @animating
    nextSlide = @currentSlide + 1
    nextSlide = 0 if nextSlide >= @slides.length
    @galleryMove nextSlide

  galleryPrev: ->
    return if @animating
    nextSlide = @currentSlide - 1
    nextSlide = @slides.length - 1 if nextSlide <= 0
    @galleryMove nextSlide, true

  galleryMove: (slide, toLeft)->
    cur = @slides[@currentSlide]
    next = @slides[slide]
    @loadSlide next
    @animStarted()
    Velocity cur, { left: ["#{if toLeft then '' else '-'}100%", 'easeOutQuad', 0], scale: [0.8, 'easeOutExpo', 1] }, {
      duration: @transitionDuration * 2, display: 'none'
    }
    Velocity next, { left: [0, 'easeOutQuad', "#{if toLeft then '-' else ''}100%"], scale: [1, 'easeInExpo', 0.8] }, {
      duration: @transitionDuration * 2, display: 'block', complete: => @animEnded()
    }
    @currentSlide = slide

  loadSlide: (slide)->
    unless slide.style.backgroundImage
      imageSrc = slide.getAttribute('data-image')
      img = new Image
      img.onload = ((slide)->->
        slide.loader?.stop()
        slide.style.backgroundImage = "url('#{this.src}')"
      )(slide)
      img.src = imageSrc
    
  animStarted: ->
    @animating = true
    addClass document.body, 'disable-hover'

  animEnded: ->
    @animating = false
    removeClass document.body, 'disable-hover'