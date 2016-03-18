chai = require('chai')
chai.should()
sinon = require 'sinon'
chai.use require 'sinon-chai'
chai.use require 'chai-as-promised'


Window = require '../../src/supersonic/mock/window'
steroids = require '../../src/supersonic/mock/steroids'
steroids.view.params = {bar: "baz"}

logger = require('../../src/supersonic/core/logger')(steroids, new Window())
views = require('../../src/supersonic/core/ui/views')(steroids, logger, new Window())

describe "supersonic.ui.views", ->
  it "should be an object", ->
    views.should.be.an 'object'

describe "supersonic.ui.views.current", ->
  current = views.current

  it "should be an object", ->
    current.should.be.an 'object'

  describe "params", ->
    params = current.params

    it "should be an object", ->
      params.should.be.an 'object'

    it "should have bar", ->
      spy = sinon.spy()
      params.onValue spy
      spy.should.have.been.calledWith {bar: "baz"}

    it "should trigger onValue callback on paramsBus.push", ->
      spy = sinon.spy()

      params.onValue spy
      current.paramsBus.push {foo: "bar"}
      spy.should.have.been.calledWith {foo: "bar"}
