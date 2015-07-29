class HomeController

  constructor: (@container)->
    @logo = @container.getElementsByClassName('compound_logo')[0]
    @trackCursor = hasClass @logo, 'track'
    @logoInner = @logo.getElementsByClassName('inner')[0]
    @logoOuter = @logo.getElementsByClassName('outer')[0]
    @scroller = @container.getElementsByClassName('scroller')[0]

    @init()
    @bind()

  bind: ->
    @container.addEventListener 'mousemove', (e)=>
      return unless @trackCursor
      angle = 65
      w = @container.offsetWidth
      h = @container.offsetHeight
      pos = e.clientX - w/2
      deg = pos / (w/2) * angle
      pos2 = e.clientY - h/2
      deg2 = pos2 / (h/2) * angle

      @logoInner.style.transform = "rotateY(#{deg}deg) rotateX(#{deg2 * -1}deg)"
      @logoInner.style.WebkitTransform = "rotateY(#{deg}deg) rotateX(#{deg2 * -1}deg)"
      @logoOuter.style.transform = "rotateY(#{deg * 1}deg) rotateX(#{deg2}deg)"
      @logoOuter.style.WebkitTransform = "rotateY(#{deg * 1}deg) rotateX(#{deg2}deg)"

    @scroller.addEventListener 'click', -> window.router.goto 1

  init: ->
    @scrollerAnimate()

  scrollerAnimate: ->
    arrow = @scroller.getElementsByTagName('img')[0]
    Velocity arrow, {
      top: ['50%', 0]
    }, {
      duration: 750
      progress: (e, progress)->
        v = if progress <= 0.5 then progress * 2 else (1 - progress) * 2
        e[0].style.opacity = v
      complete: => @scrollerAnimate()
    }