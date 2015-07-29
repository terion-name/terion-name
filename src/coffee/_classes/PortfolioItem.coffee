class PortfolioItem

  constructor: (@item, @container, @workContainer)->
    @item.controller = this
    @isSimple = hasClass @item, 'simple'
    @row = 0
    @column = 0
    @width = 0
    @height = 0
    @url = @item.getElementsByClassName('details')[0].getAttribute('href')

    @item.style.position = 'absolute' unless @isSimple

    @bind()

  bind: ->
    @item.getElementsByClassName('details')[0]?.addEventListener 'click', (e)=>
      e.preventDefault()
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
    if not tranitionDuration or tranitionDuration == 0
      @item.style.left = left + 'px'
      @item.style.top = top + 'px'
      @item.style.width = @width + 'px'
      @item.style.height = @height + 'px'
    else
      Velocity @item, {
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
    promise.get(customUrl or @url).then (error, text, xhr)=>
      #console.log text
      if (error)
        console.error error
        #TODO handle error
      else
        parser = new DOMParser()
        doc = parser.parseFromString(text, "text/html");

        work = document.createElement 'div'
        work.className = 'work_overlay'
        work.innerHTML = doc.getElementById('work').innerHTML

        workCntrl = new WorkController work
        workCntrl.appear (w)->
          FB?.XFBML.parse w.container
          twttr?.widgets.load()
        @workContainer.appendChild work
        for s in work.getElementsByTagName('script')
          eval s.innerHTML
          
        window.history?.pushState({index: 1, work: @url}, '', @url) unless noPopState
        