
waitForModalShow = ->
  new Promise (resolve) ->
    listener = window.top.steroids.modal.on "didshow", ->
      window.top.steroids.modal.off "didshow", listener
      resolve()

waitForModalHide = ->
  new Promise (resolve) ->
    listener = window.top.steroids.modal.on "didclose", ->
      window.top.steroids.modal.off "didclose", listener
      resolve()

describe 'supersonic.module.modal', ->
  it 'is an object', ->
    supersonic.module.should.have.property('modal').be.an 'object'

  before ->
    supersonic.env.modules ?= {}
    supersonic.env.modules.routes =
      foo:
        views:
          index:
            path: "app/module/empty.html"

  describe 'show', ->
    it 'is a function', ->
      supersonic.module.modal.should.have.property('show').be.a 'function'

  describe 'hide', ->
    it 'is a function', ->
      supersonic.module.modal.should.have.property('hide').be.a 'function'

  describe 'navigation between views', ->

    xit 'can show a view matching a given route and can hide it afterwards', ->
      supersonic.module.modal.show('foo')
        .then(waitForModalShow)
        .then(supersonic.module.modal.hide)
        .then(waitForModalHide)
        .should.be.fulfilled

    xit 'works with an installed module', ->
      supersonic.module.modal.show('com.appgyver.install-test')
        .then(waitForModalShow)
        .then(supersonic.module.modal.hide)
        .then(waitForModalHide)
        .should.be.fulfilled
