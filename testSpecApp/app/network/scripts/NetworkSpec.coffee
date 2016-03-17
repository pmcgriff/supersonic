describe "CORS request", ->
  it "should make GET to www.appgyver.com that returns correct data", (done) ->
    xhr = new XMLHttpRequest()

    successfulRequest = false

    xhr.onload = ->
      titleText = xhr.responseText.match("<title>(.*)?</title>")[1]
      titleText.should.match /AppGyver/
      done()

    xhr.onerror = ->
      (false).should.be.true
      done()


    method = "GET"
    url = "http://www.appgyver.com"

    xhr.open method, url
    xhr.setRequestHeader "X-Requested-With", "XMLHttpRequest"
    xhr.send null
