Bacon = require 'baconjs'
Promise = require 'bluebird'

module.exports = (namespace, logger) ->
  ###
  Callbackifies and debuggifies a Promise-returning function
  ###
  promiseF: (name, f) -> (args..., callbacks) ->
    # Callbackify action start
    unless callbacks?.onSuccess? or callbacks?.onFailure?
      args = [args..., callbacks]
      callbacks = null

    # Debuggify action start
    logger.debug "#{namespace}.#{name} called"

    f(args...).then(
      (value) ->
        # Debuggify action success
        logger.debug "#{namespace}.#{name} resolved"

        # Callbackify action success
        if callbacks?.onSuccess?
          callbacks.onSuccess?(value)
        else
          value
      (error) ->
        # Debuggify action failure
        msg = if error?.errorDescription?
          error.errorDescription
        else
          JSON.stringify error
        logger.error "#{namespace}.#{name} rejected: #{msg}"

        # Callbackify action failure
        if callbacks?.onFailure?
          callbacks.onFailure(error)
        else
          Promise.reject error
    )

  ###
  Callbackify and debuggify a stream-returning function
  ###
  streamF: (name, f) -> (args..., callbacks) ->
    # Callbackify stream start
    unless callbacks?.onSuccess? or callbacks?.onFailure?
      args = [args..., callbacks]
      callbacks = null

    # Debuggify stream start
    logger.debug "#{namespace}.#{name} called"

    stream = f(args...)
      .mapError((error) ->
        # Debuggify stream error
        logger.error "#{namespace}.#{name} produced an error: #{error}"
        new Bacon.Error error
      )

    # Callbackify stream value
    if callbacks?.onSuccess?
      stream.onValue callbacks.onSuccess

    # Callbackify stream error
    if callbacks?.onFailure?
      stream.onError callbacks.onFailure

    stream
