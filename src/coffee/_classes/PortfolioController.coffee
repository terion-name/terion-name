class PortfolioController

  #
  # It should be more correct to create a class for each display mode with a single interface
  # and separate them. But in this case it doesn't make sense due to simplicity of the task
  #

  constructor: (@container)->

    @mode = 'grid_big'
    @listOverlay = false
    @animating = false
    @transitionTime = 250

    @works = @container.getElementsByClassName('works')[0]
    @worksWraper = @works.getElementsByClassName('wraper')[0]
    @items = @worksWraper.getElementsByClassName('item')
    @listView = @container.getElementsByClassName('works-list-display')[0]
    @listViewItems = @listView.getElementsByClassName('item')
    #@sizers = @works.getElementsByClassName('sizer')
    @controls = @container.getElementsByClassName('controls')[0]
    @controlButtons = @controls.getElementsByClassName('filter-button')
    @displayModeButtons = @controls.getElementsByClassName('display_mode')
    @goRight = @container.getElementsByClassName('nav_right')[0]
    @goLeft = @container.getElementsByClassName('nav_left')[0]

    @init()
    @bind()

  init: ->
    @adaptWraper()
    @updateFilter()
    @arrange()
    #do =>
    #  sizer = new Image()
    #  sizer.onload = =>
    #    @adaptWraper()
    #    @arrange()
    #    @checkArrows()
    #  sizer.src = '/img/sizer_16x9.png'
    @checkArrows()

  bind: ->
    window.addEventListener 'resize', =>
      @fixChrome()
      @adaptWraper()
      @arrange()
      @checkArrows()

    for item in @items
      item.getElementsByClassName('details')[0]?.addEventListener 'click', (e)=>
        e.preventDefault()
        @loadWork e.target.getAttribute('href')

    for controlButton in @controlButtons
      controlButton.addEventListener 'click', (e)=>
        return if @animating
        if hasClass e.target, 'active' then removeClass e.target, 'active' else addClass e.target, 'active'
        @updateFilter()

    for displayButton in @displayModeButtons
      displayButton.addEventListener 'click', (e)=>
        return if @animating
        @changeDisplayMode e.target.getAttribute('data-type')
        removeClass b, 'active' for b in @displayModeButtons
        addClass e.target, 'active'

    @goRight.addEventListener 'click', (e)=> @navRight()
    @goLeft.addEventListener 'click', (e)=> @navLeft()

  # fix a Chrome bug that exists since 2010...
  # in fact it sometimes appears in other webkits too, so let it be for everyone
  fixChrome: ->
    ###
    Well, this was fixing reflow lag in Chrome on inline-block elements.
    But a bug in Firefox forced to manually set all dimensions of items.
    After that this fix became obsolete. Let it be here commented out just in case
    for sizer in @sizers
      sizer.style.display = 'inline-block'
      sizer.offsetHeight
      sizer.style.display = ''
    ###

  getVisibleItems: ->
    visibleItems = []
    for e in @items
      visibleItems.push(e) if e.style.display != 'none' and not hasClass e, 'hide'
    return visibleItems

  adaptWraper: ->
    @works.style.bottom = @controls.offsetHeight + 'px'
    if @mode == 'grid_big'
      visible = @getVisibleItems()
      colWidth = visible[0]?.offsetWidth
      @worksWraper.style.width = (Math.ceil(visible.length / 2) * colWidth) + 'px'

      wraperMargin = parseFloat @worksWraper.style.marginLeft or 0
      if wraperMargin > 0 or @worksWraper.offsetWidth < @works.offsetWidth
        @worksWraper.style.marginLeft = 0
      else if @worksWraper.offsetWidth + wraperMargin < @works.offsetWidth
        @worksWraper.style.marginLeft = @works.offsetWidth - @worksWraper.offsetWidth + 'px'

    else if @mode == 'grid_small'
      @worksWraper.style.width = '100%'

  navRight: ->
    return if @animating or @mode != 'grid_big'

    visibleItems = @getVisibleItems()
    return unless visibleItems.length
    moveOn = visibleItems[0].offsetWidth * Math.ceil(@works.offsetWidth / 2 / visibleItems[0].offsetWidth)
    currentMargin = parseFloat @worksWraper.style.marginLeft or 0

    if  @worksWraper.offsetWidth - moveOn + currentMargin < @works.offsetWidth
      moveOn = @worksWraper.offsetWidth - @works.offsetWidth + currentMargin

    @animStarted()
    Velocity @worksWraper, {
      marginLeft: "-=#{moveOn}px"
    }, {
      easing: 'easeOutQuad'
      complete: =>
        @checkArrows()
        @animEnded()
    }

  navLeft: ->
    return if @animating or @mode != 'grid_big'
    currentMargin = parseFloat @worksWraper.style.marginLeft or 0

    visibleItems = @getVisibleItems()
    return unless visibleItems.length
    moveOn = visibleItems[0].offsetWidth * Math.ceil(@works.offsetWidth / 2 / visibleItems[0].offsetWidth)

    moveOn = currentMargin * -1 if moveOn > currentMargin * -1

    @animStarted()
    Velocity @worksWraper, {
      marginLeft: "+=#{moveOn}px"
    }, {
      easing: 'easeOutQuad'
      complete: =>
        @checkArrows()
        @animEnded()
    }

  checkArrows: ->
    return unless @mode == 'grid_big'

    if @worksWraper.offsetWidth < @works.offsetWidth
      @goLeft.style.left = '-25px'
      @goRight.style.right = '-25px'
    else
      wraperMargin = parseFloat @worksWraper.style.marginLeft or 0
      if wraperMargin >= 0
        @goLeft.style.left = '-25px'
      else
        @goLeft.style.left = ''
      if @worksWraper.offsetWidth + wraperMargin <= @works.offsetWidth
        @goRight.style.right = '-25px'
      else
        @goRight.style.right = ''

  arrange: (transition)->
    visibleItems = @getVisibleItems()
    if @mode == 'grid_big'
      i = 0
      colWidth = @worksWraper.offsetHeight / 2 / 9 * 16
      rowHeight = @worksWraper.offsetHeight / 2

      removeClass @works, 'grid_small'
      removeClass @works, 'hide_awards'

      for item in visibleItems
        colnum = Math.floor(i / 2)
        rownum = i % 2
        item.style.position = 'absolute'
        if transition
          @animStarted()
          Velocity item, {
            left: colnum * colWidth + 'px'
            top: rownum * 50 + '%'
            # Firefox, burn in hell...
            # height: '50%'
            height: rowHeight
            width: colWidth
          }, {
            queue: false
            easing: 'easeOutQuad'
            duration: transition
            progress: => @fixChrome()
            complete: ((i)=>=>
              if i == visibleItems.length - 1
                @fixChrome()
                @arrange() # this will fix positioning if animation lagged by some reason
                @adaptWraper()
                @checkArrows()
                @animEnded())(i)
          }
        else
          item.style.left = colnum * colWidth + 'px'
          item.style.top = rownum * 50 + '%'
          # Firefox, burn in hell...
          # item.style.height = '50%'
          item.style.height = rowHeight + 'px'
          item.style.width = colWidth + 'px'
          @checkArrows()

        ++i

    else if @mode == 'grid_small'
      size = @smallGridCalcSize()
      visibleItems = @getVisibleItems()
      i=0
      columns = size.cols
      rows = size.rows

      @worksWraper.style.marginLeft = 0
      addClass @works, 'grid_small'
      if size.height < 120
        addClass(@works, 'hide_awards')
      else
        removeClass(@works, 'hide_awards')

      for item in visibleItems
        rownum = Math.floor(i / columns)
        colnum = i - rownum * columns
        item.style.position = 'absolute'
        if transition
          @animStarted()
          Velocity item, {
            left: colnum * size.width + 'px'
            top: rownum * size.height + 'px'
            height: size.height
            width: size.width
          }, {
            duration: transition
            queue: false
            easing: 'easeOutQuad'
            progress: => @fixChrome()
            complete: ((item, i)=>=>
              if i == visibleItems.length - 1
                @animEnded()
                @fixChrome()
                @arrange()  # this will fix positioning if animation lagged by some reason
                @adaptWraper()
            )(item, i)
          }
        else
          item.style.left = colnum * size.width + 'px'
          item.style.top = rownum * size.height + 'px'
          item.style.height = size.height + 'px'
          item.style.width = size.width + 'px'
          @fixChrome()
        ++i

  updateFilter: ->
    return if @animating

    @animStarted()

    for item in nodeListToArray(@items).concat nodeListToArray @listViewItems
      multicondition = false
      exclusivecondition = true
      for btn in @controlButtons
        if hasClass btn, 'only'
          if hasClass(btn, 'active')
            exclusivecondition = false unless hasClass item, btn.getAttribute('data-type')
        else
          multicondition = true if hasClass(btn, 'active') and hasClass(item, btn.getAttribute('data-type'))

      if multicondition and exclusivecondition
        removeClass item, 'hide'
        Velocity item, {
          scale: 1
        }, {
          duration: @transitionTime
          display: 'auto'
          queue: false
          easing: 'easeOutQuad'
          complete: => @animEnded()
        }
      else
        addClass item, 'hide'
        Velocity item, {
          scale: 0
        }, {
          duration: @transitionTime
          display: 'none'
          queue: false
          easing: 'easeOutQuad'
          complete: => @animEnded()
        }

    setTimeout (=>
      @arrange(@transitionTime - 10)
      @adaptWraper()
    ), 10


  changeDisplayMode: (mode)->
    return if @animating

    if mode == 'grid_big' or mode == 'grid_small'
        @hideList()
        return if @mode == mode
        @mode = mode
        @arrange(@transitionTime)
        @adaptWraper()
    else if mode == 'list'
      return if @mode == mode
      @showList()

  smallGridCalcSize: ->
    containerWidth = @works.offsetWidth
    containerHeight = @works.offsetHeight
    visibleItems = @getVisibleItems()
    visibleItemsCount = visibleItems.length

    h = 0
    rows = 0
    w = 0
    h = 0
    calc = (rows)->
      _w = containerWidth / Math.ceil(visibleItemsCount / rows)
      _h = _w / 16 * 9
      return w: _w, h: _h

    while true
      ++rows
      c = calc(rows)
      if c.h * rows > containerHeight
        rows--
        break
      w = c.w
      h = c.h
    return {
      width: Math.floor(w)
      height: Math.floor(h)
      rows: rows
      cols: Math.ceil(visibleItemsCount/rows)
    }

  showList: ->
    return if @animating or @listOverlay
    @animStarted()
    @listOverlay = true
    Velocity @listView, {
      top: 0
    }, {
      duration: @transitionTime
      easing: 'easeOutQuad'
      display: 'block'
      complete: => @animEnded()
    }

  hideList: ->
    return if @animating or not @listOverlay
    @listOverlay = false
    @animStarted()
    Velocity @listView, {
      top: '-100%'
    }, {
      duration: @transitionTime
      easing: 'easeOutQuad'
      display: 'none'
      complete: => @animEnded()
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
        @container.appendChild work

  animStarted: ->
    @animating = true
    addClass document.body, 'disable-hover'

  animEnded: ->
    @animating = false
    removeClass document.body, 'disable-hover'