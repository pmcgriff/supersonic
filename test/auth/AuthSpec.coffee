chai = require('chai')
chai.should()
chai.use require 'chai-as-promised'
expect = chai.expect

request = require 'superagent'
btoa = require 'btoa'
Promise = require 'bluebird'

steroids = require '../../src/supersonic/mock/steroids'
Window = require '../../src/supersonic/mock/window'

global = new Window()
global.appgyver =
  environment: require '../../config/environments/supersonicdatatestapp'

logger = require('../../src/supersonic/core/logger')(steroids, global)
env = require('../../src/supersonic/core/env')(logger, global)
data = require('../../src/supersonic/core/data')(logger, global, env)

login = new Promise (resolve, reject) ->
  request.post env.auth.endpoint + "/session"
    .send
      type: 'appgyver'
      credentials:
        username: 'demo'
        password: 'demo'
    .set 'Content-Type', 'application/json'
    .set 'Accept', 'application/json'
    .set 'Authorization', 'ag_rest_auth ' + btoa "#{env.app.id}:#{env.app.tokens.data}"
    .end (err, res)->
      if err?
        reject err
        return
      resolve JSON.parse res.text

beLoggedIn = login.then (sessionData)->
  data.session.set sessionData
# .then data.users.getCurrentUser

describe 'supersonic.auth', ->
  @timeout 10000

  describe 'with session data from a production environment', ->
    it 'has a valid user id', ->
      beLoggedIn.then ->
        data.session.getUserId().should.eq 31024

    it 'has a valid access token', ->
      beLoggedIn.then ->
        token = data.session.getAccessToken()
        token.should.be.a.string
        token.should.not.be.empty
        token.should.have.length 32

    # it 'has a valid current user', ->
    #   beLoggedIn.then (user)->
    #     user.should.not.be.empty

    describe 'with a test resource collection', ->
      foundAll = null
      deletedAll = null
      beforeEach ->
        foundAll = beLoggedIn.then data.model('TestResource').findAll

      it 'deletes everything initially', (done)->
        deletedAll = foundAll.then (things)->
          Promise.all (thing.delete() for thing in things)
        .then -> done()

      it 'has no data after deleting everything', (done)->
        deletedAll.then data.model('TestResource').findAll
        .tap (things)->
          things.should.be.empty
        .then -> done()

    describe 'with a new record', ->
      beReadyToCreate = beLoggedIn.then -> data.model('TestResource')
      createdOne = null

      it 'creates a record successfully', ->
        beReadyToCreate.then (TestResource)->
          newThing = new TestResource {
            Text: "Test1"
            LongText: "Test 1 Longtext is looong."
            Date: new Date()
            # User: ???
            Number: 42
            Link: "www.appgyver.com"
            # Image: ???
            # Money: ???
            Progress: 50
            # File: ???
            Status: "good"
            Phone_number: "+3580800118844"
            Email: "contact+recruitment@appgyver.com"
          }
          createdOne = newThing.save().then ->
            newThing.__state.should.eq 'persisted'
            newThing.id.should.not.be.empty

      describe 'finding some records', ->
        foundAll = null
        beforeEach ->
          foundAll = createdOne.then data.model('TestResource').findAll

        it 'finds a collection of records', ->
          foundAll.then (things)->
            things.should.not.be.empty
            things.should.have.length 1

        describe 'selecting the first record', ->
          foundOne = null
          beforeEach ->
            foundOne = foundAll.get 0 #first
            .get 'id'
            .then data.model('TestResource').find

          it 'finds a single record', ->
            foundOne.then (thing)->
              thing.Text.should.eq 'Test1'

          it 'updates a single found record', ->
            foundOne.then (thing)->
              thing.Text = 'Test2'
              thing.save()
              .tap ->
                thing.__dirty.should.be.falsy
              .get 'id'
              .then data.model('TestResource').find
              .then (updatedThing)->
                updatedThing
                updatedThing.Text.should.eq 'Test2'
