class Header
  
  constructor: (@container)->
    @isHomeMode = true
    @topMenu = @container.getElementsByClassName('top_menu')[0]
    @logo = @container.getElementsByClassName('logo')[0]
    @bind()
    
  bind: ->
    window.router.onScreenChange = (num)=> @updateActive(num)
    
    @logo.addEventListener 'click', (e)-> window.router.loadScreen {index: 0},null, true
    
    for link in @topMenu.getElementsByTagName('a')
      link.addEventListener 'click', (e)=>
        if document.getElementsByClassName('screen').length > 1
          e.preventDefault()
          window.router.loadScreen {index: parseInt(e.target.getAttribute 'data-screen')},null, true
          
  homeMode: (active)->
    return if active == @homeMode
    @isHomeMode = active
    @updateMode()

  updateMode: ->
    if @isHomeMode
      addClass @container, 'home'
    else
      removeClass @container, 'home'

  updateActive: (num)->
    for li, i in @topMenu.getElementsByTagName('li')
      if num == i
        addClass li, 'active'
      else
        removeClass li, 'active'