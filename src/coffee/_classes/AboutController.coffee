class AboutController

  constructor: (@container)->
    @employmentExpander = @container.getElementsByClassName('employment_expand')[0]
    
    @init()
    @bind()
    
  init: ->
    currentLi = @employmentExpander.parentNode
    li = currentLi.nextSibling
    while li
      li.style.display = 'none'
      li = li.nextSibling
    
  bind: ->
    @employmentExpander.addEventListener 'click', (e)=>
      if hasClass @employmentExpander, 'expanded'
        @implodeEmployment()
        @employmentExpander.innerText = 'show more'
        removeClass @employmentExpander, 'expanded'
      else
        @expandEmployment()
        @employmentExpander.innerText = 'show less'
        addClass @employmentExpander, 'expanded'
      
  expandEmployment: ->
    currentLi = @employmentExpander.parentNode
    li = currentLi.nextSibling
    while li
      Velocity li, 'slideDown', { duration: 250 }
      li = li.nextSibling
      
  implodeEmployment: ->
    currentLi = @employmentExpander.parentNode
    li = currentLi.nextSibling
    while li
      Velocity li, 'slideUp', { duration: 250 }
      li = li.nextSibling