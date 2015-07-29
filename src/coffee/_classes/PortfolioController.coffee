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
    @items = []
    @listView = @container.getElementsByClassName('works-list-display')[0]
    @listViewItems = []
    @controls = @container.getElementsByClassName('controls')[0]
    @controlButtons = @controls.getElementsByClassName('filter-button')
    @displayModeButtons = @controls.getElementsByClassName('display_mode')
    @goRight = @container.getElementsByClassName('nav_right')[0]
    @goLeft = @container.getElementsByClassName('nav_left')[0]

    @init()
    @bind()

  init: ->
    for item in @worksWraper.getElementsByClassName('item')
      @items.push new PortfolioItem item, @worksWraper, @container
      
    for item in @listView.getElementsByClassName('item')
      @listViewItems.push new PortfolioItem item, @worksWraper, @container

    @adaptWraper()
    @updateFilter()
    @arrange(0)
    @checkArrows()

  bind: ->
    window.addEventListener 'resize', =>
      @adaptWraper()
      @arrange()
      @checkArrows()

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

  getVisibleItems: ->
    visibleItems = []
    for e in @items
      visibleItems.push(e) if e.item.style.display != 'none' and not hasClass e.item, 'hide'
    return visibleItems

  adaptWraper: ->
    @works.style.bottom = @controls.offsetHeight + 'px'
    if @mode == 'grid_big'
      visible = @getVisibleItems()
      colWidth = visible[0]?.item.offsetWidth
      @worksWraper.style.width = (Math.ceil(visible.length / 2) * colWidth) + 'px'
      wraperMargin = parseFloat @worksWraper.style.marginLeft or 0
      if wraperMargin > 0 or @worksWraper.offsetWidth < @works.offsetWidth
        @worksWraper.style.marginLeft = 0
      else if @worksWraper.offsetWidth + wraperMargin < @works.offsetWidth
        @worksWraper.style.marginLeft = @works.offsetWidth - @worksWraper.offsetWidth + 'px'
    else
      @worksWraper.style.width = '100%'

  navRight: ->
    return if @animating or @mode != 'grid_big'
    visibleItems = @getVisibleItems()
    return unless visibleItems.length
    moveOn = visibleItems[0].item.offsetWidth * Math.ceil(@works.offsetWidth / 2 / visibleItems[0].item.offsetWidth)
    currentMargin = parseFloat @worksWraper.style.marginLeft or 0
    if  @worksWraper.offsetWidth - moveOn + currentMargin < @works.offsetWidth
      moveOn = @worksWraper.offsetWidth - @works.offsetWidth + currentMargin
    @navItems moveOn

  navLeft: ->
    return if @animating or @mode != 'grid_big'
    currentMargin = parseFloat @worksWraper.style.marginLeft or 0
    visibleItems = @getVisibleItems()
    return unless visibleItems.length
    moveOn = visibleItems[0].item.offsetWidth * Math.ceil(@works.offsetWidth / 2 / visibleItems[0].item.offsetWidth)
    moveOn = currentMargin * -1 if moveOn > currentMargin * -1
    @navItems moveOn, true


  navItems: (moveOn, toLeft)->
    @animStarted()
    Velocity @worksWraper, { marginLeft: "#{if toLeft then '+' else '-'}=#{moveOn}px" },
      easing: 'easeOutQuad'
      complete: =>
        @checkArrows()
        @animEnded()

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
      removeClass @works, 'grid_small'
      removeClass @works, 'hide_awards'
      colWidth = @worksWraper.offsetHeight / 2 / 9 * 16
      rowHeight = @worksWraper.offsetHeight / 2
      coordsCalc = (index)->
        colnum = Math.floor(i / 2)
        rownum = i % 2
        return col: colnum, row: rownum
    else
      size = @smallGridCalcSize()
      colWidth = size.width
      rowHeight = size.height
      coordsCalc = (index)->
        rownum = Math.floor(i / size.cols)
        colnum = i - rownum * size.cols
        return col: colnum, row: rownum

      @worksWraper.style.marginLeft = 0
      addClass @works, 'grid_small'
      if size.height < 120
        addClass(@works, 'hide_awards')
      else
        removeClass(@works, 'hide_awards')

    onComplete = =>
      @arrange() if transition # this will fix positioning if animation lagged by some reason
      @adaptWraper()
      @checkArrows()
      @animEnded()

    @animStarted() if transition
    i = 0
    for item in visibleItems
      pos = coordsCalc(i)
      item.setRow(pos.row)
      item.setColumn(pos.col)
      item.setSize(colWidth, rowHeight)
      if i == visibleItems.length - 1
        item.place(transition, onComplete)
      else
        item.place(transition)
      ++i
    onComplete() unless transition


  updateFilter: ->
    return if @animating

    @animStarted()

    for item in @items.concat nodeListToArray @listViewItems
      multicondition = false
      exclusivecondition = true
      node = if item.item then item.item else item
      for btn in @controlButtons
        if hasClass btn, 'only'
          if hasClass(btn, 'active')
            exclusivecondition = false unless hasClass node, btn.getAttribute('data-type')
        else
          multicondition = true if hasClass(btn, 'active') and hasClass(node, btn.getAttribute('data-type'))

      if multicondition and exclusivecondition
        removeClass node, 'hide'
        Velocity node, { scale: 1 },
          duration: @transitionTime
          display: 'auto'
          queue: false
          easing: 'easeOutQuad'
          complete: => setTimeout (=> @animEnded()), 10
      else
        addClass node, 'hide'
        Velocity node, { scale: 0 },
          duration: @transitionTime
          display: 'none'
          queue: false
          easing: 'easeOutQuad'
          complete: => setTimeout (=> @animEnded()), 10

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
    Velocity @listView, { top: 0 },
      duration: @transitionTime
      easing: 'easeOutQuad'
      display: 'block'
      complete: => @animEnded()

  hideList: ->
    return if @animating or not @listOverlay
    @listOverlay = false
    @animStarted()
    Velocity @listView, { top: '-100%' },
      duration: @transitionTime
      easing: 'easeOutQuad'
      display: 'none'
      complete: => @animEnded()

  animStarted: ->
    @animating = true
    addClass document.body, 'disable-hover'

  animEnded: ->
    @animating = false
    removeClass document.body, 'disable-hover'