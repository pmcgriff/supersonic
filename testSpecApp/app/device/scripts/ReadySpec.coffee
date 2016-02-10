describe "supersonic.device.ready", ->
  it "should work", (done)->
    supersonic.device.ready.should.exist
    supersonic.device.ready.then ()->
      done()
