
Promise = require 'bluebird'
data = require 'ag-data'

module.exports = (logger, superglobal, env) ->
  channel = require('./channel')(superglobal)
  property = require('./storage/property')(logger, superglobal, channel)
  adapters = require('./storage/adapters')(superglobal)

  syncLocalStorage = require('./storage/adapters/sync-local-storage')(superglobal)
  session = require('./session')(syncLocalStorage)

  defaultAsyncStorageAdapter = adapters.localStorage

  model = require('./model')(logger, superglobal, defaultAsyncStorageAdapter, session, env)
  storage = { adapters, property }

  requests = data.requests

  {
    channel
    model
    storage
    session
    requests
  }
