describe "supersonic.ui.dialog.confirm", ->
  @timeout 10000

  it "should be defined", ->
    supersonic.ui.dialog.confirm.should.exist

  it "should present a confirm", ->
    supersonic.ui.dialog.confirm().should.be.fulfilled

  it "should present a confirm with null params", ->
    supersonic.ui.dialog.confirm(null).should.be.fulfilled

  it "should present a confirm with title as param", ->
    supersonic.ui.dialog.confirm("What up?").should.be.fulfilled

  it "should present a confirm with title and options params", ->
    title = "I'm a Custom Confirm!"
    options =
      message: "Custom Message"
      buttonLabels: ["Yay","NO!","third"]

    supersonic.ui.dialog.confirm(title, options).should.be.fulfilled

  describe "callbacks", ->

    it "should call onSuccess", (done) ->
      supersonic.ui.dialog.confirm
        onSuccess: ->
          done()
