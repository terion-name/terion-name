fit = (fromW, fromH, toW, toH, round)->
  targetW = 0
  targetH = 0

  ratio1 = fromW / fromH
  ratio2 = toW / toH
  leading = if ratio1 > ratio2 then 'w' else 'h'
  if leading == 'w'
    targetW = toW
    targetH = targetW / ratio1
  else
    targetH = toH
    targetW = targetH * ratio1

  return [Math.round(targetW), Math.round(targetH)] if round
  return [targetW, targetH]

fill = (fromW, fromH, toW, toH, round)->
  targetW = 0
  targetH = 0
  marginLeft = 0
  marginTop = 0

  ratio1 = fromW / fromH
  ratio2 = toW / toH
  leading = if ratio1 < ratio2 then 'w' else 'h'
  if leading == 'w'
    targetW = toW
    targetH = targetW / ratio1
    marginTop = (toH - targetH) / 2
  else
    targetH = toH
    targetW = targetH * ratio1
    marginLeft = (toW - targetW) / 2

  return [Math.round(targetW), Math.round(targetH), Math.round(marginLeft), Math.round(marginTop)] if round
  return [targetW, targetH, marginLeft, marginTop]

addClass = (o, c) ->
  re = new RegExp('(^|\\s)' + c + '(\\s|$)', 'g')
  if re.test(o.className)
    return
  o.className = (o.className + ' ' + c).replace(/\s+/g, ' ').replace(/(^ | $)/g, '')
  return

removeClass = (o, c) ->
  re = new RegExp('(^|\\s)' + c + '(\\s|$)', 'g')
  o.className = o.className.replace(re, '$1').replace(/\s+/g, ' ').replace(/(^ | $)/g, '')
  return

hasClass = (o, c) ->
  re = new RegExp('(^|\\s)' + c + '(\\s|$)', 'g')
  return re.test(o.className)

nodeListToArray = (nodeList)->
  arr = []
  # seems this is faster then Array.prototype.slice
  for node in nodeList
    arr.push node
  return arr


### inspired by https://gist.github.com/1129031 ###
###global document, DOMParser###
do (DOMParser) ->
  'use strict'
  proto = DOMParser.prototype
  nativeParse = proto.parseFromString
  # Firefox/Opera/IE throw errors on unsupported types
  try
  # WebKit returns null on unsupported types
    if (new DOMParser).parseFromString('', 'text/html')
      # text/html parsing is natively supported
      return
  catch ex

  proto.parseFromString = (markup, type) ->
    if /^\s*text\/html\s*(?:;|$)/i.test(type)
      doc = document.implementation.createHTMLDocument('')
      if markup.toLowerCase().indexOf('<!doctype') > -1
        doc.documentElement.innerHTML = markup
      else
        doc.body.innerHTML = markup
      doc
    else
      nativeParse.apply this, arguments

  return


trim = (str, charlist) ->
  # Strip whitespace (or other characters) from the beginning and end of a string
  #
  # +   original by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  # +   improved by: mdsjack (http://www.mdsjack.bo.it)
  # +   improved by: Alexander Ermolaev (http://snippets.dzone.com/user/AlexanderErmolaev)
  # +	  input by: Erkekjetter
  # +   improved by: Kevin van Zonneveld (http://kevin.vanzonneveld.net)
  charlist = if !charlist then ' s ' else charlist.replace(/([\[\]\(\)\.\?\/\*\{\}\+\$\^\:])/g, '$1')
  re = new RegExp('^[' + charlist + ']+|[' + charlist + ']+$', 'g')
  str.replace re, ''


getQueryParams = (queryString)->
  assoc = {}

  decode = (s) -> decodeURIComponent s.replace(/\+/g, ' ')

  queryString = location.search.substring(1) unless queryString
  keyValues = queryString.split('&')
  for i of keyValues
    key = keyValues[i].split('=')
    if key.length > 1
      assoc[decode(key[0])] = decode(key[1])
  assoc


transitionEndEventName = ->
  el = document.createElement('div')
  transitions =
    'transition': 'transitionend'
    'OTransition': 'otransitionend'
    'MozTransition': 'transitionend'
    'WebkitTransition': 'webkitTransitionEnd'
  for i of transitions
    if transitions.hasOwnProperty(i) and el.style[i] != undefined
      return transitions[i]
  #TODO: throw 'TransitionEnd event is not supported in this browser'; 
  return

once = (node, type, callback)->
  # create event
  node.addEventListener type, (e) ->
    # remove event
    e.target.removeEventListener e.type, arguments.callee
    # call handler
    callback e
  return

getLocation = (href) ->
  match = href.match(/^(https?\:)\/\/(([^:\/?#]*)(?:\:([0-9]+))?)(\/[^?#]*)(\?[^#]*|)(#.*|)$/)
  match and
    protocol: match[1]
    host: match[2]
    hostname: match[3]
    port: match[4]
    pathname: match[5]
    search: match[6]
    hash: match[7]