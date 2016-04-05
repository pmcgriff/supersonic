class Attach
  constructor: (@element, @namespace) ->
    for k, v of @element.dataset
      @namespace.attributes.set k.replace(/[A-Z]/g, (letter) -> "-#{letter.toLowerCase()}"), v

  namespace: ->
    @namespace

module.exports = (attributesFactory) ->
  (element) ->
    ->
      attributes = attributesFactory()
      instance = new Attach(element, {attributes})
      return instance.namespace
