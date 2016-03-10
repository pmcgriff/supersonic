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

getTestModel = ->
  data.model('TestResource')

describe 'supersonic.auth', ->
  @timeout 10000

  describe 'with session data from a production environment', ->
    it 'has a valid user id', ->
      beLoggedIn.then ->
        data.session.getUserId().should.be.above 1

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
        foundAll = beLoggedIn.then getTestModel().findAll

      it 'deletes everything initially', (done)->
        deletedAll = foundAll.then (things)->
          Promise.all (thing.delete() for thing in things)
        .then -> done()

      it 'has no data after deleting everything', (done)->
        deletedAll.then getTestModel().findAll
        .tap (things)->
          things.should.be.empty
        .then -> done()

    describe 'with a new record', ->
      beReadyToCreate = beLoggedIn.then getTestModel
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
            Money: 99.99
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
          foundAll = createdOne.then getTestModel().findAll

        it 'finds a collection of records', ->
          foundAll.then (things)->
            things.should.not.be.empty
            things.should.have.length 1

        describe 'selecting the first record', ->
          foundOneId = null
          beforeEach ->
            foundOneId = foundAll.get 0 #first
            .get 'id'

          it 'finds a single record', ->
            foundOneId
            .then getTestModel().find
            .then (thing)->
              thing.Text.should.eq 'Test1'

          it 'updates a single found record', ->
            foundOneId
            .then getTestModel().find
            .then (thing)->
              thing.Text = 'Test2'
              thing.save()
              .tap ->
                thing.__dirty.should.be.falsy
              .get 'id'
              .then getTestModel().find
              .then (updatedThing)->
                updatedThing
                updatedThing.Text.should.eq 'Test2'

          it 'finds a single record without ACL by default', ->
            foundOneId
            .then getTestModel().find
            .then (thing)->
              thing.should.have.property 'acl'
              expect(thing.acl).to.be.undefined

          it 'finds a single record with ACL included', ->
            foundOneId.then (id)->
              getTestModel().find id, include_acl: true
            .then (thing)->
              thing.should.have.property 'acl'
              thing.acl.should.not.be.empty

          describe "and updating the ACL", ->

            it 'updates a single records ACL', ->
              foundOneId.then (id)->
                getTestModel().find id, include_acl: true
              .then (thing)->
                aclRuleForUser = thing.acl[0]
                aclRuleForUser.remove.should.be.true
                aclRuleForUser.remove = false
                thing.save()
                .tap (savedThing)->
                  savedThing.acl.should.not.be.empty
                  savedThing.acl.length.should.eq 1
                  aclRuleForUser = savedThing.acl[0]
                  aclRuleForUser.read.should.be.true
                  aclRuleForUser.remove.should.be.false
                .then (savedThing)->
                  getTestModel().find savedThing.id, include_acl: true
                .then (updatedThing)->
                  updatedThing.should.have.property 'acl'
                  updatedThing.acl.should.not.be.empty
                  updatedThing.acl.length.should.eq 1
                  aclRuleForUser = updatedThing.acl[0]
                  aclRuleForUser.read.should.be.true
                  aclRuleForUser.remove.should.be.false

            it 'replaces a single records ACL', ->
              foundOneId.then (id)->
                getTestModel().find id, include_acl: true
              .then (thing)->
                thing.acl.should.not.be.empty
                thing.acl.length.should.eq 1
                thing.acl = []
                thing.acl.should.be.empty
                thing.save()
                .tap (savedThing)->
                  savedThing.acl.should.be.empty
                  savedThing.acl.length.should.eq 0
                .then (savedThing)->
                  getTestModel().find savedThing.id, include_acl: true
                .then (updatedThing)->
                  updatedThing.should.have.property 'acl'
                  expect(updatedThing.acl).to.be.null

            it 'replaces a single records ACL with a new ACL rule', ->
              foundOneId.then (id)->
                getTestModel().find id, include_acl: true
              .then (thing)->
                expect(thing.acl).to.be.null
                thing.acl = [{something_invalid: true}]
                thing.acl.should.not.be.empty
                thing.save()
                .tap (savedThing)->
                  thing.acl.should.not.be.empty
                  savedThing.acl.length.should.eq 1
                  savedThing.acl[0].something_invalid.should.be.truthy
                .then (savedThing)->
                  getTestModel().find savedThing.id, include_acl: true
                .then (updatedThing)->
                  updatedThing.should.have.property 'acl'
                  updatedThing.acl.length.should.eq 1
                  updatedThing.acl[0].something_invalid.should.be.truthy


        describe 'selecting the first record with one()', ->
          foundOneId = null
          beforeEach ->
            foundOneId = foundAll.get 0 #first
            .get 'id'

          it 'listens for changes in a single record with ACL', (done)->
            foundOneId
            .tap (id)->
              options =
                interval: 100
                query:
                  include_acl: true

              success = (thing)->
                thing.Text.should.eq 'Test2'
                thing.should.have.property 'acl'
                thing.acl.should.not.be.empty
                thing.acl.length.should.eq 1
                done()

              getTestModel().one(id, options).whenChanged success, done
