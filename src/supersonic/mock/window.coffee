localStorage = require('./localStorage')

class Window
  constructor: ->
    @parent = @
    @localStorage = localStorage()

  location:
    href: ''
  AG_SCREEN_ID: 0
  AG_LAYER_ID: 0
  AG_VIEW_ID: 0

  document:
    addEventListener: ->
    body:
      querySelectorAll: -> []

  postMessage: ->

module.exports = Window
