module.exports = do ->

  callbacks = {}

  uniqueId = (length=8) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length

  fakeEvent = (namespace) ->
    unless callbacks[namespace]?
      callbacks[namespace] = {}

    (event_name, f) ->
      cbObj = {id: uniqueId(), fn: f}
      if callbacks[namespace][event_name]?
        callbacks[namespace][event_name].push cbObj
      else
        callbacks[namespace][event_name] = [cbObj]

      return cbObj.id

  removeEvent = (namespace) ->
    (event_name, id) ->
      callbacks[namespace][event_name] = (cb for cb in callbacks[namespace][event_name] when cb.id != id)
      return true

  triggerEvent = (namespace, event_name, argz...) ->
    cbs = callbacks[namespace][event_name]
    if cbs?
      #console.log "Triggering fake event #{namespace}: #{event_name} callbacks (#{cbs.length})"
      for cb in cbs
        cb.fn.apply(null, argz)

  __trigger_event: triggerEvent
  device:
    ping: ->
  app:
    host:
      getURL: ->
    getMode: ->
  tabBar:
    on: fakeEvent("steroids.tabBar.on")
    off: removeEvent("steroids.tabBar.on")
  drawers:
    on: fakeEvent("steroids.drawers.on")
    off: removeEvent("steroids.drawers.on")
  view:
    params: {}
    on: fakeEvent("steroids.view.on")
    off: removeEvent("steroids.view.on")
  getApplicationState: (params, callbacks) ->
    callbacks.onFailure?()
