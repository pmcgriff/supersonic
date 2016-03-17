describe "supersonic.device.accelerometer", ->
  it "should be defined", ->
    supersonic.device.accelerometer.should.exist

  checkAccelerationObject = (a) ->
    a.should.be.defined
    a.x.should.be.defined
    a.x.should.be.a "number"
    a.y.should.be.defined
    a.y.should.be.a "number"
    a.z.should.be.defined
    a.z.should.be.a "number"
    a.timestamp.should.be.defined

  checkReasonableValues = (a) ->
    reasonableThreshold = 15

    a.x.should.be.below reasonableThreshold
    a.x.should.be.above reasonableThreshold * -1
    a.y.should.be.below reasonableThreshold
    a.y.should.be.above reasonableThreshold * -1
    a.z.should.be.below reasonableThreshold
    a.z.should.be.above reasonableThreshold * -1

  checkRecentTimestamp = (a) ->
    recently = (new Date()).getTime() - 2000
    reasonableTimeLimit = recently + 7000

    a.timestamp.should.be.above recently
    a.timestamp.should.be.below reasonableTimeLimit

  describe "getAcceleration", ->
    it "should exist and be a function", ->
      supersonic.device.accelerometer.getAcceleration.should.be.defined
      supersonic.device.accelerometer.getAcceleration.should.be.a "function"

    xit "should resolve to a proper Acceleration object", (done) ->
      supersonic.device.accelerometer.getAcceleration().then (a) ->
        checkAccelerationObject(a)
        done()

    xit "the Acceleration object should have (reasonable) values for x, y and z expressed in m/s^2", (done) ->
      supersonic.device.accelerometer.getAcceleration().then (a) ->
        checkReasonableValues(a)
        done()

    xit "the Acceleration object should return a recent timestamp", (done) ->
      supersonic.device.accelerometer.getAcceleration().then (a) ->
        checkRecentTimestamp(a)
        done()

    describe "callbacks", ->

      xit "should call onSuccess", (done) ->
        supersonic.device.accelerometer.getAcceleration
          onSuccess: ->
            done()

  describe "watchAcceleration", ->
    it "should be defined and a function", ->
      supersonic.device.accelerometer.watchAcceleration.should.be.defined
      supersonic.device.accelerometer.watchAcceleration.should.be.a "function"

    xit "should return a stream of Acceleration objects", (done) ->
      supersonic.device.accelerometer.watchAcceleration().onValue (a) ->
        checkAccelerationObject(a)
        done()

    xit "should have (reasonable) values for x, y and z expressed in m/s^2", (done) ->
      supersonic.device.accelerometer.watchAcceleration().onValue (a) ->
        checkReasonableValues(a)
        done()

    xit "the Acceleration object should return a recent timestamp", (done) ->
      supersonic.device.accelerometer.watchAcceleration().onValue (a) ->
        checkRecentTimestamp(a)
        done()

    describe "callbacks", ->

      xit "should call onSuccess", (done) ->
        supersonic.device.accelerometer.watchAcceleration
          onSuccess: ->
            done()
