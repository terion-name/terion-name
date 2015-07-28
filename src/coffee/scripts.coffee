#= require_tree _classes

if portfolioContainer = document.getElementById 'portfolio'
  new PortfolioController portfolioContainer

if homeContainer = document.getElementById 'home'
  new HomeController homeContainer
