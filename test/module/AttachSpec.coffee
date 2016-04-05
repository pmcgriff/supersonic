chai = require('chai')
chai.should()

steroids = require '../../src/supersonic/mock/steroids'
Window = require '../../src/supersonic/mock/window'

global = new Window()
logger = require('../../src/supersonic/core/logger')(steroids, global)
attributes = require('../../src/supersonic/core/module/attributes')

attributesFactory = ->
  attributes(logger, global)

attach = require('../../src/supersonic/core/module/attach')(attributesFactory)

node =
  dataset:
    "foo": "bar"
    "module": ""

node2 =
  dataset:
    "foo": "bar2"

describe "attach", ->
  it "should be defined", ->
    attach.should.be.defined

  it "should be a function", ->
    attach.should.be.a "function"

  describe "when attached", ->
    attached = null
    attached2 = null

    before ->
      attached = attach(node)()
      attached2 = attach(node2)()

    describe ".attributes", ->
      attrs = null

      before ->
        attrs = attached.attributes

      it "should be defined", ->
        attrs.should.be.defined

      describe ".get", ->

        it "foo", ->
          val = attrs.get "foo"
          val.should.be.defined
          val.should.equal "bar"

        it "module", ->
          val = attrs.get "module"
          val.should.be.defined
          val.should.equal ""

        it "does not mix up with other attached instance", ->
          attached2.attributes.get("foo").should.equal "bar2"
