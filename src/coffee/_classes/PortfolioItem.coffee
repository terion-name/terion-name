class PortfolioItem

  constructor: (@item, @container, @workContainer)->
    @row = 0
    @column = 0
    @width = 0
    @height = 0

    @item.style.position = 'absolute'

    @bind()

  bind: ->
    @item.getElementsByClassName('details')[0]?.addEventListener 'click', (e)=>
      e.preventDefault()
      @loadWork e.target.getAttribute('href')

  setRow: (row)-> @row = row

  setColumn: (column)-> @column = column

  setSize: (width, height)->
    @width = width
    @height = height

  place: (tranitionDuration, callback)->
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

  loadWork: (url)->
    promise.get(url).then (error, text, xhr)=>
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
        workCntrl.appear()
        @workContainer.appendChild work