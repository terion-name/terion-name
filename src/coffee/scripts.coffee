#= require_tree _classes

window.appInit = ->
  window.siteHeader = new Header document.getElementById 'header'

  if portfolioContainer = document.getElementById 'portfolio'
    new PortfolioController portfolioContainer

  if homeContainer = document.getElementById 'home'
    new HomeController homeContainer

  if aboutContainer = document.getElementById 'about'
    new AboutController aboutContainer

  if workContainer = document.getElementById 'work'
    new WorkController workContainer

window.router = new Router document.getElementById 'container'