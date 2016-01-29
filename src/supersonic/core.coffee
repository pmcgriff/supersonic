without = require './util/without'
pick = require './util/pick'

global = if window?
    window
  else
    Window = require './mock/window'
    new Window()

superglobal = do ->
  candidate = global
  # Find the topmost frame with supersonic
  while candidate.parent? and (candidate.parent isnt candidate) and (candidate.parent.supersonic?)
    candidate = candidate.parent
  candidate

steroids = do ->
  frame = global
  candidate = frame.steroids

  # Find the topmost frame that has steroids
  while frame.parent? and (frame.parent isnt frame)
    frame = frame.parent
    if frame.steroids?.version?
      candidate = frame.steroids

  if candidate?.version?
    candidate
  else
    require './mock/steroids'

logger = require('./core/logger')(steroids, global)
env = require('./core/env')(logger, superglobal)
data = require('./core/data')(logger, superglobal, env)
ui = require('./core/ui')(steroids, logger, global, superglobal, data)

module.exports = {
  logger
  env
  ui
  data: without ['users', 'groups', 'session'], data
  auth: pick ['users', 'groups', 'session'], data
  debug: require('./core/debug')(steroids, logger)
  app: require('./core/app')(steroids, logger)
  media: require('./core/media')(steroids, logger)
  module: require('./core/module')(steroids, logger, superglobal, ui, env, global, data)
  device: require('./core/device')(steroids, logger)
  internal:
    Promise: require 'bluebird'
    Bacon: require 'baconjs'
}

# Export to window as global if we're in the browser
if (window?)
  window.supersonic = module.exports
  window.supersonic.logger.autoFlush()
