describe "supersonic.auth", ->

  it "should be defined", ->
    supersonic.should.have.property('auth')

  describe "users", ->
    it "should be defined", ->
      supersonic.auth.should.have.property('users')

    describe "findAll()", ->
      xit "should return at least one user", ->
        supersonic.auth.users.findAll().then (users) ->
          users.length.should.be.greaterThan 0

    describe "getCurrentUser()", ->
      xit "should return a user", ->
        supersonic.auth.users.getCurrentUser().then (user) ->
          user.should.have.property('username')

  describe "session", ->
    it "should be defined", ->
      supersonic.auth.should.have.property('session')

    describe "when authenticated", ->
      describe "getAccessToken", ->
        it "should return a string", ->
          supersonic.auth.session.getAccessToken().should.be.a 'string'

      describe "getUserId", ->
        it "should return a number", ->
          supersonic.auth.session.getUserId().should.be.a 'number'

    describe "when not authenticated", ->
      sessionData = null

      before ->
        sessionData = supersonic.auth.session.get()
        supersonic.auth.session.clear()

      describe "getAccessToken", ->
        it "should not exist", ->
          expect(supersonic.auth.session.getAccessToken()).to.not.exist

      describe "getUserId", ->
        it "should not exist", ->
          expect(supersonic.auth.session.getUserId()).to.not.exist

      after ->
        supersonic.auth.session.set sessionData
