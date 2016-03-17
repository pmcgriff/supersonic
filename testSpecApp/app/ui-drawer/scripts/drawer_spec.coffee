describe "supersonic.ui.drawers", ->
  # THESE TESTS CAN ONLY BE RUN ONCE IN APP LIFECYCLE (BECAUSE NO DRAWER UNLOAD)

  it "should be defined", ->
    supersonic.ui.drawers.should.exist

  it "should be able to use a started view", ->
    receivedMessage = new Promise (resolve) ->
      listener = (e) ->
        return if e.data == "process-tick"
        window.removeEventListener "message", listener
        resolve e.data
      window.addEventListener "message", listener

    view = new supersonic.ui.View "/app/ui-drawer/postback.html?msg=custom"
    view.start("custom-id-left-drawer").then ->
      supersonic.ui.drawers.init(view, side: "left", width: 100).should.be.fulfilled
      receivedMessage.should.eventually.equal "custom"

  it "should be able to update options", ->
    supersonic.ui.drawers.updateOptions(
      shadow: false
      animation:
        type: "parallax"
        duration: 0.3
    ).should.be.fulfilled

  describe "opening unstarted views", ->

    it "should be able to init right drawer", ->
      receivedMessage = new Promise (resolve) ->
        listener = (e) ->
          return if e.data == "process-tick"
          supersonic.logger.log "Received message: #{JSON.stringify(e.data)}"
          window.removeEventListener "message", listener
          resolve e.data
        window.addEventListener "message", listener

      supersonic.ui.drawers.init("/app/ui-drawer/postback.html?msg=right", side: "right").should.be.fulfilled
      receivedMessage.should.eventually.equal "right"

    it "should not be able to init right again without custom id", ->
      supersonic.ui.drawers.init("/app/ui-drawer/postback.html?msg=right", side: "right").should.be.rejected

    it "should be able to init left drawer", ->
      receivedMessage = new Promise (resolve) ->
        listener = (e) ->
          return if e.data == "process-tick"
          window.removeEventListener "message", listener
          resolve e.data
        window.addEventListener "message", listener

      supersonic.ui.drawers.init("/app/ui-drawer/postback.html?msg=left", side: "left").should.be.fulfilled
      receivedMessage.should.eventually.equal "left"

    it "should not be able to init left again without custom id", ->
      supersonic.ui.drawers.init("/app/ui-drawer/postback.html?msg=left", side: "left").should.be.rejected

  describe "opening and closing", ->
    it "should be able to show left drawer", (done) ->
      (new Promise (resolve) ->
        steroids.drawers.on "didshow", resolve
      ).should.be.fulfilled.and.notify done

      supersonic.ui.drawers.open("left").should.be.fulfilled


    it "should be able to close left drawer", (done) ->
      (new Promise (resolve) ->
        steroids.drawers.on "didclose", resolve
      ).should.be.fulfilled.and.notify done

      supersonic.ui.drawers.close().should.be.fulfilled

    it "should be able to show right drawer", (done) ->
      (new Promise (resolve) ->
        steroids.drawers.on "didshow", resolve
      ).should.be.fulfilled.and.notify done

      supersonic.ui.drawers.open("right").should.be.fulfilled

    it "should be able to close right drawer", (done) ->
      (new Promise (resolve) ->
        steroids.drawers.on "didclose", resolve
      ).should.be.fulfilled.and.notify done

      supersonic.ui.drawers.close().should.be.fulfilled
