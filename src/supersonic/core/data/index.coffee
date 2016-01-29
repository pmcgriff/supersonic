
Promise = require 'bluebird'
data = require 'ag-data'

module.exports = (logger, superglobal, env) ->
  channel = require('./channel')(superglobal)
  property = require('./storage/property')(logger, superglobal, channel)
  adapters = require('./storage/adapters')(superglobal)

  syncLocalStorage = require('./storage/adapters/sync-local-storage')(superglobal)
  session = require('./session')(syncLocalStorage)

  defaultAsyncStorageAdapter = adapters.localStorage

  loadResourceBundle = require('./model/load-resource-bundle')(logger, session, defaultAsyncStorageAdapter)
  model = require('./model')(logger, superglobal, env, loadResourceBundle)
  users = require('./users')(env, session, loadResourceBundle)
  groups = require('./groups')(env, session, loadResourceBundle)

  {
    channel
    model
    session
    users
    groups
    storage: { adapters, property }
    requests: data.requests
  }
