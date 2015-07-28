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