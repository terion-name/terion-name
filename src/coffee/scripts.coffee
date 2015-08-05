#= require_tree _classes

window.appInit = ->
  window.siteHeader = new Header document.getElementById 'header'
  window._transitionEndEventName = transitionEndEventName()

  if portfolioContainer = document.getElementById 'portfolio'
    new PortfolioController portfolioContainer

  if homeContainer = document.getElementById 'home'
    new HomeController homeContainer

  if aboutContainer = document.getElementById 'about'
    new AboutController aboutContainer

  if workContainer = document.getElementById 'work'
    new WorkController workContainer

  setTimeout (->
    globalLoader = document.getElementById('global_loader')
    if globalLoader
      addClass globalLoader, 'hide'
      setTimeout (-> globalLoader.parentNode.removeChild(globalLoader)), 1000
  ), 300
  

window.router = new Router document.getElementById 'container'