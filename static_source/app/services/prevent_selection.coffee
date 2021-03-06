
#
# написано по статье
# http://habrahabr.ru/post/18080/
#

preventSelection = (element) ->
  `var preventSelection`
  preventSelection = false
  # не даем выделять текст мышкой

  addHandler = (element, event, handler) ->
    if element.attachEvent
      element.attachEvent 'on' + event, handler
    else if element.addEventListener
      element.addEventListener event, handler, false
    return

  removeSelection = ->
    if window.getSelection
      window.getSelection().removeAllRanges()
    else if document.selection and document.selection.clear
      document.selection.clear()
    return

  killCtrlA = (event) ->
    `var event`
    event = event or window.event
    sender = event.target or event.srcElement
    if sender.tagName.match(/INPUT|TEXTAREA/i)
      return
    key = event.keyCode or event.which
    if event.ctrlKey and key == 'A'.charCodeAt(0)
      removeSelection()
      if event.preventDefault
        event.preventDefault()
      else
        event.returnValue = false
    return

  addHandler element, 'mousemove', ->
    if preventSelection
      removeSelection()
    return
  addHandler element, 'mousedown', (event) ->
    `var event`
    event = event or window.event
    sender = event.target or event.srcElement
    preventSelection = !sender.tagName.match(/INPUT|TEXTAREA/i)
    return
  # борем dblclick
  # если вешать функцию не на событие dblclick, можно избежать
  # временное выделение текста в некоторых браузерах
  addHandler element, 'mouseup', ->
    if preventSelection
      removeSelection()
    preventSelection = false
    return
  # борем ctrl+A
  # скорей всего это и не надо, к тому же есть подозрение
  # что в случае все же такой необходимости функцию нужно
  # вешать один раз и на document, а не на элемент
  addHandler element, 'keydown', killCtrlA
  addHandler element, 'keyup', killCtrlA
  return

# ---
# generated by js2coffee 2.1.0