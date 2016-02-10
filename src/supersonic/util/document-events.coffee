Promise = require 'bluebird'
Bacon = require 'baconjs'

module.exports =
  deviceready:
    if document?
      new Promise (resolve) ->
        document.addEventListener 'deviceready', resolve
    else
      Promise.resolve()

  background: do ->
    pauses = if document?
      Bacon.fromEventTarget(document, "pause").map -> true
    else
      Bacon.once true
    resumes = if document?
      Bacon.fromEventTarget(document, "resume").map -> false
    else
      Bacon.once true
    pauses.merge(resumes)
      .toProperty()
      .skipDuplicates()

  network: do ->
    offlines = if document?
      Bacon.fromEventTarget(document, "offline").map -> false
    else
      Bacon.once true
    onlines = if document?
      Bacon.fromEventTarget(document, "online").map -> true
    else
      Bacon.once true

    offlines.merge(onlines)
      .toProperty()
      .skipDuplicates()

  visibility: do ->
    visibilityState = if document?
        changes: Bacon.fromEventTarget(document, 'visibilitychange')
        defaultState: document.visibilityState
      else
        changes: Bacon.once target: visibilitystate: 'visible'
        defaultState: 'hidden'

    visibilityState.changes
      .map((event) ->
        if event.detail?.visibilityState?
          event.detail.visibilityState
        else
          event.target?.visibilityState
      )
      .toProperty(visibilityState.defaultState)
      .map((stateString) ->
        switch stateString
          when "visible" then true
          when "hidden" then false
          else false
      )
