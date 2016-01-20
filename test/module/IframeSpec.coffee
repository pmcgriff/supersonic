chai = require('chai')
chai.should()

iframes = require('../../src/supersonic/core/module/iframes')(global = {}, superglobal = {})

describe 'supersonic.module.iframes', ->
  it 'is an object', ->
    iframes.should.be.an 'object'

  describe 'findAll', ->
    it 'is a function', ->
      iframes.should.have.property('findAll').be.a 'function'

    it 'should return an empty array when there is no document body', ->
      iframes.findAll().should.deep.equal []
