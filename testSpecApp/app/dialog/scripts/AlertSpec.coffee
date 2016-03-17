dismissNextAlert = ->
  steroids.screen.on "alertdidshow", ->
    steroids.screen.dismissAlert
      buttonIndex: 0

describe "supersonic.ui.dialog.alert", ->
  @timeout 10000

  it "should be defined", ->
    supersonic.ui.dialog.alert.should.exist

  it "should present and dismiss alert", ->
    dismissNextAlert()
    supersonic.ui.dialog.alert().should.be.fulfilled

  it "should present and dismiss alert with null params", ->
    dismissNextAlert()
    supersonic.ui.dialog.alert(null).should.be.fulfilled

  it "should present and dismiss alert with custom title", ->
    dismissNextAlert()
    supersonic.ui.dialog.alert("Custom Title").should.be.fulfilled

  it "should present and dismiss alert with title string and options object as params", ->

    title = "I'm an alert!"
    options =
      message: "Custom message"
      buttonLabel: "Close"

    dismissNextAlert()
    supersonic.ui.dialog.alert(title, options).should.be.fulfilled

  describe "callbacks", ->

    it "should call onSuccess", (done) ->
      supersonic.ui.dialog.alert
        onSuccess: ->
          done()
