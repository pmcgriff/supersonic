Bacon = require 'baconjs'
Promise = require 'bluebird'
events = require '../../../util/document-events'
channel = require '../../data/channel'


module.exports = (steroids, log, global) ->
  parameterBus = new Bacon.Bus

  viewObject = {
    paramsBus: parameterBus
    params: parameterBus.toProperty(steroids?.view?.params)
    id: null
  }

  # find out if view is started or not (based on current URL matching)
  isStarted = ->
    new Promise (resolve, reject) ->
      steroids.getApplicationState {},
        onSuccess: (state) ->
          matches = (preload for preload in state.preloads when global.location.href in [preload.URL, preload.location]) # iOS: .URL Android: .location
          if matches.length and matches[0].id?
            resolve matches[0].id
          else
            reject()
        onFailure: ->
          reject(new Error("Could not get application state"))

  isStarted().then(
    (startedWithId) ->
      viewObject.id = startedWithId
      channelId = "view-params-#{viewObject.id}"
      unlisten = null

      viewChannel = channel(global)(channelId)
      parameterBus.plug viewChannel.inbound
    ->
      log.debug "View '#{global.location.href}' is not started, will not register channel"
  )

  ###
   # @namespace supersonic.ui.views
   # @name current
   # @overview
   # @description
   # Provides access to the current view and it's visibility state.
   #
   # ## Methods
   # * [whenVisible](/supersonic/api-reference/stable/supersonic/ui/views/current/whenvisible/) – registers a listener that is triggered when the view becomes visible.
   # * [whenHidden](/supersonic/api-reference/stable/supersonic/ui/views/current/whenhidden/) – registers a listener that is triggered when the view becomes hidden.
   # * [params.onValue](/supersonic/api-reference/stable/supersonic/ui/views/current/params-onvalue/) – access the parameters passed to this view by a navigation action.
  ###

  viewObject.visibility = events.visibility
  ###
   # @namespace supersonic.ui.views.current
   # @name whenVisible
   # @function
   # @apiCall supersonic.ui.views.current.whenVisible
   # @description
   # Trigger a function when the current view becomes visible.
   # @type
   # supersonic.ui.views.current.whenVisible: (
   #   listen: Function
   # ) => unsubscribe: Function
   # @define {Function} listen A function that is triggered when the view becomes visible.
   # @returnsDescription
   # A function that can be used to unsubscribe from listening to view visibility events.
   # @define {=>Function} unsubscribe When called, stops listening for view visibility events.
   # @exampleCoffeeScript
   # stopListening = supersonic.ui.views.current.whenVisible ->
   #   supersonic.logger.debug "This view is now visible"
   #   stopListening()
   # @exampleJavaScript
   # var stopListening = supersonic.ui.views.current.whenVisible( function() {
   #   supersonic.logger.debug("This view is now visible");
   #   stopListening();
   # });
  ###
  viewObject.whenVisible = (listen) ->
    events.visibility
      .filter((visible) -> visible)
      .onValue listen

  ###
   # @namespace supersonic.ui.views.current
   # @name whenHidden
   # @function
   # @apiCall supersonic.ui.views.current.whenHidden
   # @description
   # Trigger a function when the current view becomes hidden.
   # @type
   # supersonic.ui.views.current.whenHidden: (
   #   listen: Function
   # ) => unsubscribe: Function
   # @define {Function} listen A function that is triggered when the view becomes hidden.
   # @returnsDescription
   # A function that can be used to unsubscribe from view visibility events.
   # @define {=>Function} unsubscribe When called, stops listening for view visibility events.
   # @exampleCoffeeScript
   # stopListening = supersonic.ui.views.current.whenHidden ->
   #   supersonic.logger.debug "This view is now hidden."
   #   stopListening()
   # @exampleJavaScript
   # var stopListening = supersonic.ui.views.current.whenHidden( function() {
   #   supersonic.logger.debug("This view is now hidden");
   #   stopListening();
   # });
  ###
  viewObject.whenHidden = (listen) ->
    events.visibility
      .filter((visible) -> !visible)
      .onValue listen

  ###
   # @namespace supersonic.ui.views.current
   # @name subscribe
   # @function
   # @description
   # Listens for the current view events.
   # @type
   # supersonic.ui.views.current.subscribe: (
   #   eventName: String
   #   listener: Function
   # ) => unsubscribe: Function
   # @define {String} eventName Name of the event. Valid event names include: willchange, didchange, blocked, preloaded
   # @define {Function} listener Event handler function that is called when the event is triggered. It receives the eventContext as a parameter.
   # @returnsDescription
   # A function that can be used to unsubscribe the listener from any future events.
   # @exampleCoffeeScript
   # unsubscribe = supersonic.ui.views.current.subscribe "preloaded", (event) ->
   #   console.log event
   #   unsubscribe()
   #
   # @exampleJavaScript
   # var unsubscribe = supersonic.ui.views.current.subscribe("preloaded", function (event) {
   #   console.log(event);
   #   unsubscribe()
   # });
  ###
  viewObject.subscribe = (eventName, listener) ->
    viewObject.events(eventName).onValue listener

  viewObject.events = (eventName) ->
    Bacon.fromBinder (sink) ->
      eventHandlerId = steroids.view.on eventName, sink

      unsubscribe = ->
        steroids.view.off eventName, eventHandlerId

  # pass view object so that params & id can be changed from here
  viewObject

  ###
   # @namespace supersonic.ui.views.current
   # @name params.onValue
   # @function
   # @apiCall supersonic.ui.views.current.params.onValue
   # @description
   # A [stream](/supersonic/guides/technical-concepts/streams) that contains the latest navigation parameters passed to this view. Note that the stream always contains the latest parameters if they are available, so even if parameters have been set for this view already, you can still use the stream to access them.
   # @type
   # supersonic.ui.views.current.params.onValue: (
   #   callback: Function
   # ) => unsubscribe: Function
   # @define {Function} callback A function that gets triggered every time the view receives new navigation parameters. The function gets triggered with the new parameters object as as a parameter.
   # @returnsDescription
   # A function that can be used to unsubscribe from the parameters stream.
   # @define {=>Function} unsubscribe When called, unsubscribes from the parameters stream.
   # @exampleCoffeeScript
   # stopListening = supersonic.ui.views.current.params.onValue (params) ->
   #   supersonic.logger.debug "New value for the id param is: #{params.id}"
   #
   # # Later on, we can stop listening to the stream.
   # stopListening()
   # @exampleJavaScript
   # var stopListening = supersonic.ui.views.current.params.onValue( function(params) {
   #   supersonic.logger.debug("Newest value for the id param is: " + params.id);
   # });
   #
   # // Later on, we can stop listening to the stream.
   # stopListening();
  ###
