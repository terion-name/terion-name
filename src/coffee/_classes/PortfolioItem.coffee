class PortfolioItem

  constructor: (@item, @container, @workContainer)->
    @item.controller = this
    @isSimple = hasClass @item, 'simple'
    @row = 0
    @column = 0
    @width = 0
    @height = 0
    @url = @item.getElementsByClassName('details')[0].getAttribute('href')
    @freeze = false

    @item.style.position = 'absolute' unless @isSimple

    @bind()

  bind: ->
    @item.getElementsByClassName('details')[0]?.addEventListener 'click', (e)=>
      e.preventDefault()
      return if @freeze
      @loadWork()

  setRow: (row)-> @row = row

  setColumn: (column)-> @column = column

  setSize: (width, height)->
    @width = width
    @height = height

  place: (tranitionDuration, callback)->
    return if @isSimple
    left = @column * @width
    top = @row * @height

    # seriously, css animation in safari works worse... oh
    # but they work better in others
    # don't really want to make a user-agent based decision. let it be css for time being
    cssAnim = true
    if cssAnim
      if not tranitionDuration or tranitionDuration == 0
        removeClass @item, 'anim'
      else
        addClass @item, 'anim'
      setTimeout (=>
        @item.style.left = left + 'px'
        @item.style.top = top + 'px'
        @item.style.width = @width + 'px'
        @item.style.height = @height + 'px'
        if not tranitionDuration or tranitionDuration == 0
          callback(@item) if callback
        else
          once @item, window._transitionEndEventName, => callback(@item) if callback
      ), 5
    else
      if not tranitionDuration or tranitionDuration == 0
        @item.style.left = left + 'px'
        @item.style.top = top + 'px'
        @item.style.width = @width + 'px'
        @item.style.height = @height + 'px'
        callback(@item) if callback
      else
        Velocity @item, {
          translateZ: 0
          left: left + 'px'
          top: top + 'px'
          width: @width + 'px'
          height: @height + 'px'
        }, {
          duration: tranitionDuration
          easing: 'easeOutQuad'
          queue: false
          complete: => callback(@item) if callback
        }

  loadWork: (noPopState, customUrl)->
    @freeze = true
    loader = new Loader @item
    loader.start()
    promise.get(customUrl or @url).then (error, text, xhr)=>
      if (error)
        console.error error
        loader.stop()
        @freeze = false
        #TODO handle error
      else
        parser = new DOMParser()
        doc = parser.parseFromString(text, "text/html");
        doc.getElementsByClassName('desc')[0].style.display = 'none'
        doc.getElementsByClassName('gallery')[0].style.display = 'none'

        work = document.createElement 'div'
        work.className = 'work_overlay'
        work.innerHTML = doc.getElementById('work').innerHTML

        @workContainer.appendChild work
        workCntrl = new WorkController work

        workCntrl.appear (w)->
          for s in work.getElementsByTagName('script')
            eval s.innerHTML
          FB?.XFBML.parse w.container
          twttr?.widgets.load()
          
        window.history?.pushState({index: 1, work: @url}, '', @url) unless noPopState
        loader.stop()
        @freeze = false