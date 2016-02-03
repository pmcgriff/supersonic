debug = require('debug')('supersonic:auth:session')

module.exports = (localStorage) ->
  new class Session

    RAW_SESSION_KEY: "__ag:data:session"
    storage: localStorage

    set: (rawSession) =>
      validateSession rawSession
      debug "Setting session data", rawSession
      @storage.setItem @RAW_SESSION_KEY, rawSession

    get: =>
      @storage.getItem @RAW_SESSION_KEY

    clear: =>
      debug "Clearing session data", rawSession
      @storage.removeItem @RAW_SESSION_KEY

    getAccessToken: =>
      @get()?.access_token

    getUserId: =>
      @get()?.user_details?.id

validateSession = (rawSession) ->
  unless isValidRawSession(rawSession)
    throw new SessionValidationError "Invalid data for session", rawSession

isValidRawSession = (session) ->
  session.access_token? && session.user_details?.id?

class SessionValidationError extends Error

  constructor: (@message, @errors) ->
    Error.call @
    Error.captureStackTrace?(@, @constructor)
    @name = @constructor.name

  toString: ->
    "#{@name}(#{@message}, #{JSON.stringify @errors})"
