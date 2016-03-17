describe "supersonic.app.getLaunchURL", ->
  it "should be defined", ->
    supersonic.app.getLaunchURL.should.exist

  it "should initially return null", ->
    urlObject = supersonic.app.getLaunchURL()
    expect(urlObject).to.be.null

  xit "should return object after calling openURL with steroids-scanner:// scheme", (done) ->
    supersonic.app.openURL("steroids-scanner://?user=quentin&password=monkey").then ->
      supersonic.app.getLaunchURL().should.be.an "object"
      done()

  xit "should return an object containing the launchURL", ->
    urlObject = supersonic.app.getLaunchURL()
    urlObject.launchURL.should.be.a "string"

  xit "should return an object containing the given params", ->
    urlObject = supersonic.app.getLaunchURL()
    urlObject.params.user.should.equal "quentin"
    urlObject.params.password.should.equal "monkey"
