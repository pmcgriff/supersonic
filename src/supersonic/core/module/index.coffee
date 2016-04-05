
module.exports = (steroids, logger, superglobal, ui, env, global, data) ->
  attributes = require('./attributes')

  attributesFactory = ->
    attributes(logger, global)

  router = require('./router')(logger, env, global)
  drivers = require('./drivers')(steroids, superglobal, global)

  cordovaSupport = require('./cordova-support')(superglobal, global)
  cordovaSupport.init()

  # Set default driver unless it has been set in a parent frame
  if !drivers.current.get()?
    drivers.current.set(drivers.mpa)

  {
    router
    drivers
    cordovaSupport
    attributes: attributes(logger, global)
    attach: require('./attach')(attributesFactory)
    tabset: require('./tabset')(global)
    iframes: require('./iframes')(global, superglobal)
    layers: require('./layers')(logger, router, drivers.current.get, global)
    modal: require('./modal')(logger, router, drivers.current.get, global)
    notifications: require('./notifications')(data, attributes, data.session)
    transitions: require('./transitions')(steroids, ui, logger)
  }
