describe "supersonic.ui.dialog.prompt", ->
  @timeout 10000

  it "should be defined", ->
    supersonic.ui.dialog.prompt.should.exist

  it "should present a prompt", ->
    supersonic.ui.dialog.prompt().should.be.fulfilled

  it "should present a prompt with null params", ->
    supersonic.ui.dialog.prompt(null).should.be.fulfilled

  it "should present a prompt with title as param", ->
    supersonic.ui.dialog.prompt("Please type").should.be.fulfilled

  it "should present a prompt with title string and options object params", ->
    title = "I'm a Custom Prompt!"
    options =
      message: "Custom Message"
      buttonLabels: ["Yay","NO!"]
      defaultText: "Default text"

    supersonic.ui.dialog.prompt(title, options).should.be.fulfilled

  describe "callbacks", ->

    it "should call onSuccess", (done) ->
      supersonic.ui.dialog.prompt
        onSuccess: ->
          done()
