
waitForLayerChange = ->
  new Promise (resolve) ->
    listener = window.top.steroids.layers.on "didchange", ->
      window.top.steroids.layers.off "didchange", listener
      resolve()

describe 'supersonic.module.layers', ->
  it 'is an object', ->
    supersonic.module.should.have.property('layers').be.an 'object'

  before ->
    supersonic.env.modules ?= {}
    supersonic.env.modules.routes =
      foo:
        views:
          index:
            path: "app/module/empty.html"

      'will-reply-foo':
        views:
          index:
            path: "app/module/will-reply-foo.html"

      'will-reply-required-foo':
        views:
          index:
            path: "app/module/will-reply-foo.html"
            params:
              foo:
                required: true

  describe 'push', ->
    it 'is a function', ->
      supersonic.module.layers.should.have.property('push').be.a 'function'

  describe 'pop', ->
    it 'is a function', ->
      supersonic.module.layers.should.have.property('pop').be.a 'function'

  describe 'navigation between views', ->

    it 'can push a view matching a given route and can pop it afterwards', ->
      supersonic.module.layers.push('foo')
        .then(waitForLayerChange)
        .then(supersonic.module.layers.pop)
        .then(waitForLayerChange)
        .should.be.fulfilled

    it 'works with an installed module', ->
      supersonic.module.layers.push('com.appgyver.install-test')
        .then(waitForLayerChange)
        .then(supersonic.module.layers.pop)
        .then(waitForLayerChange)
        .should.be.fulfilled

    xit 'supports module attribute passing', ->
      foo = "foo-#{Math.random()}"
      fooReply = new Promise (resolve) ->
        supersonic.data.channel('expecting-value-from-foo')
          .inbound
          .take(1)
          .onValue resolve
      supersonic.module.layers.push('will-reply-foo', { foo })
        .then(waitForLayerChange)
        .then(->
          fooReply
        )
        .tap(supersonic.module.layers.pop)
        .tap(waitForLayerChange)
        .should.eventually.equal foo

    xit 'supports module attribute passing with required attributes', ->
      foo = "foo-#{Math.random()}"
      fooReply = new Promise (resolve) ->
        supersonic.data.channel('expecting-value-from-foo')
          .inbound
          .take(1)
          .onValue resolve
      supersonic.module.layers.push('will-reply-required-foo', { foo })
        .then(waitForLayerChange)
        .then(->
          fooReply
        )
        .tap(supersonic.module.layers.pop)
        .tap(waitForLayerChange)
        .should.eventually.equal foo
