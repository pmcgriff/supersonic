chai = require('chai')
chai.should()
chai.use require 'chai-as-promised'
expect = chai.expect

Promise = require 'bluebird'
Bacon = require 'baconjs'

steroids = require '../../src/supersonic/mock/steroids'
Window = require '../../src/supersonic/mock/window'
logger = require('../../src/supersonic/core/logger')(steroids, new Window())

asyncStorageAdapter = require('../../src/supersonic/core/data/storage/adapters')(new Window).memory
syncStorageAdapter = require('../../src/supersonic/mock/localStorage')

data = (resourceBundle = null) ->
  window = new Window()
  window.ag = {
    data: resourceBundle
  }

  session = require('../../src/supersonic/core/data/session')(syncStorageAdapter())
  loadResourceBundle = require('../../src/supersonic/core/data/model/load-resource-bundle')(logger, session, asyncStorageAdapter)
  env = {}

  model = require('../../src/supersonic/core/data/model')(
    logger
    window
    env
    loadResourceBundle
  )

  return {
    model
    session
  }

describe "supersonic.data", ->

  mockResourceBundle =
    options:
      baseUrl: "http://example.com"
    resources:
      foo: schema: fields: bar: {}

  mockSession =
    access_token: 'here is the token'
    user_details:
      id: 123

  it "accepts a resource bundle from window.ag.data", ->
    (->
      data(mockResourceBundle)
    ).should.not.throw

  describe "session", ->
    it "is a stored property", ->
      session = data().session
      session.should.respondTo 'get'
      session.should.respondTo 'set'

    it "can be set with a new session object", ->
      session = data().session
      session.set(mockSession)
      session.get().should.deep.equal mockSession

    it "should fail to set an incomplete session object", ->
      (-> data().session.set({})).should.throw Error

    describe "getAccessToken", ->
      it "is a function", ->
        data().session.should.have.property('getAccessToken').be.a 'function'

      it "returns empty when there is no session", ->
        session = data().session
        expect(session.getAccessToken()).not.to.exist

      it "returns the access token when there is a session", ->
        session = data().session
        session.set(mockSession)
        session.getAccessToken().should.equal mockSession.access_token

    describe "getUserId", ->
      it "is a function", ->
        data().session.should.have.property('getUserId').be.a 'function'

      it "returns empty when there is no session", ->
        session = data().session
        expect(session.getUserId()).not.to.exist

      it "returns the current user's id when there is a session", ->
        session = data().session
        session.set(mockSession)
        session.getUserId().should.equal mockSession.user_details.id

  describe "model", ->

    it "should be a function", ->
      data().model.should.be.a 'function'

    describe "default options", ->
      it "should have an authorization header when there is a session", ->
        d = data(mockResourceBundle)
        d.session.set mockSession

        d
          .model('foo')
          .resource
          .getOptions()
          .should
            .have.property("headers")
            .deep.equal {
              Authorization: mockSession.access_token
            }

      it "should have cache enabled", ->
        data(mockResourceBundle)
          .model('foo')
          .resource
          .should.have.property('cache')

    describe "when no resources are configured", ->
      it "should always fail", ->
        (-> data().model 'foo').should.throw Error, /no cloud resources/i

    describe "when the resource bundle is empty", ->
      it "should always fail", ->
        (-> data({}).model 'foo').should.throw Error, /could not load(.*)bundle/i

    describe "when the resource bundle has a resource", ->
      it "should return a Model class", ->
        data(mockResourceBundle)
        .model('foo')
        .should.include.keys ['find', 'findAll']

    describe "when a resource by the given name has not been defined", ->
      it "should fail", ->
        (->
          data(mockResourceBundle)
          .model('bar')
        ).should.throw Error, /could not load model/i
