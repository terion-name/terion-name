class AboutController

  constructor: (@container)->
    @employmentExpander = @container.getElementsByClassName('employment_expand')[0]
    @wraper = @container.getElementsByClassName('wrap')[0]
    
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

    @wraper.addEventListener 'wheel', (e)=>
      if @wraper.scrollHeight > @wraper.offsetHeight
        if (e.deltaY < 0 and (@wraper.scrollTop > 0)) or (e.deltaY > 0 and (@wraper.scrollTop < @wraper.scrollHeight - @wraper.offsetHeight))
          e.stopPropagation()
      
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