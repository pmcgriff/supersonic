Promise = supersonic.internal.Promise

FileFixture = do ->
  # Encodes a red dot test image
  # Source: http://en.wikipedia.org/wiki/Data_URI_scheme#Examples
  redDotDataUri = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAUAAAAFCAYAAACNbyblAAAAHElEQVQI12P4//8/w38GIAXDIBKE0DHxgljNBAAO9TXL0Y4OHwAAAABJRU5ErkJggg=="

  # Convert a data uri to an uploadable Blob
  dataUriToBlob = (dataUri) ->
    [type, encoding, content] = /data:([^;]*);([^,]*),(.*)$/.exec dataUri
    binary = atob content
    chars = (binary.charCodeAt(i) for i in [0..binary.length-1])
    new Blob(
      [new Uint8Array(chars)]
      { type }
    )

  {
    uploadableBlob: -> dataUriToBlob redDotDataUri
  }

describe "supersonic.data.model", ->
  before ->
    supersonic.auth.session.clear()

  it "is a function", ->
    supersonic.data.model.should.be.a 'function'

  describe "for any configured resource", ->
    it "returns a model class when given the name of a configured cloud resource", ->
      supersonic.data.model('SandboxTask').should.be.a 'function'

    it "receives configured cloud resources as an injected global in window.ag.data", ->
      window.ag.data.resources.SandboxTask.should.be.an 'object'

  describe "with a sandbox resource", ->

    describe "findAll", ->
      it "should be able to retrieve a collection", ->
        @timeout 5000
        SandboxTaskModel = supersonic.data.model('SandboxTask', {
          cache:
            enabled: false
        })

        SandboxTaskModel.findAll().should.be.fulfilled

    describe "all", ->
      describe "whenChanged", ->
        recordCreated = null

        it "is notified after a record is created", (done) ->
          @timeout 5000
          SandboxTaskModel = supersonic.data.model('SandboxTask', {
            cache:
              enabled: true
              timeToLive: 1000
          })

          recordCreated = SandboxTaskModel.create(description: "supersonic.data.model.all test object")

          SandboxTaskModel.all({}, interval: 1000)
            .changes
            .flatMap((tasks) ->
              supersonic.internal.Bacon.fromPromise recordCreated.then (task) ->
                for t in tasks when t.id is task.id
                  return {
                    tasks: tasks.toJson()
                    task: task.toJson()
                  }
                throw new Error "Created task not in changed tasks"
            )
            .take(1)
            .onValue ->
              done()

        afterEach ->
          recordCreated?.then (record) ->
            record.delete()

  describe "with a remote resource", ->
    describe "findAll", ->
      xit "should be able to retrieve a collection", ->
        @timeout 5000

        supersonic.data.model('BuiltIOTask', {
          cache:
            enabled: false
        }).findAll().should.be.fulfilled

  describe "with any resource", ->

    describe "supersonic.ui.isDisposable()", ->
      it "is triggered by create", ->
        supersonic.ui.isDisposable().should.equal true
        created = supersonic.data.model('SandboxTask').create({
          description: 'supersonic.data.model.create test object'
        })
        Promise.delay(10).then ->
          supersonic.ui.isDisposable().should.equal false
          created.then ->
            supersonic.ui.isDisposable().should.equal true

  describe "with a sandbox resource that has file fields", ->
    recordCreated = null
    beforeEach ->
      recordCreated = null
    afterEach ->
      recordCreated?.then (record) ->
        record.delete()

    describe "create", ->
      xit "should handle a file upload", ->
        @timeout 5000
        recordCreated = supersonic.data.model('SandboxFileResource').create({
          description: 'supersonic.data.model.create test object'
          file: FileFixture.uploadableBlob()
        })
        recordCreated.then (fileResource) ->
          fileResource.should.have.property('file').be.an 'object'
          fileResource.file.should.have.property('uploaded').equal true
          fileResource.file.should.have.property('download_url').be.a 'string'

      it "accepts an optional transaction handler", (done) ->
        @timeout 5000
        recordCreated = supersonic.data.model('SandboxFileResource').create {}, (t) ->
          done asserting ->
            t.should.be.an 'object'
            t.should.have.property('done').property('then').be.a 'function'
            t.should.have.property('abort').be.a 'function'

    describe "update", ->

      xit "should handle a file upload", ->
        # TODO: Configure from cloud
        throw new Error """
          Needs reconfiguration in the cloud.

          This will be broken until Steroids Connect gets file field support or this test app is connected to a Composer application.
        """

        recordCreated = supersonic.data.model('SandboxFileResource').create({
          description: 'supersonic.data.model.update test object'
        })
        recordCreated.then (fileResource) ->
          fileResource.should.have.property('file').property('uploaded').equal false
          supersonic.data.model('SandboxFileResource').update(fileResource.id, {
            file: FileFixture.uploadableBlob()
          }).should.eventually.have.property('file').property('uploaded').equal true

      it "accepts an optional transaction handler", (done) ->
        recordCreated = supersonic.data.model('SandboxFileResource').create({
          description: 'supersonic.data.model.update test object'
        })
        recordCreated.then (fileResource) ->
          supersonic.data.model('SandboxFileResource').update fileResource.id, {}, (t) ->
            done asserting ->
              t.should.be.an 'object'
              t.should.have.property('done').property('then').be.a 'function'
              t.should.have.property('abort').be.a 'function'

  describe "when passing in options", ->

    describe "assumptions", ->
      it "will fail to fetch any data if the correct headers are not in place", ->
        @timeout 5000
        supersonic.data.model('SandboxTask', {
          headers:
            steroidsApiKey: 'this is not the key you are looking for'
          cache:
            enabled: false
        }).findAll().should.not.be.fulfilled

    describe "behavior", ->

      it "can set headers through options", ->
        @timeout 5000
        supersonic.data.model('SandboxTask', {
          headers:
            steroidsApiKey: window.ag.data.options.headers.steroidsApiKey
            steroidsAppId: window.ag.data.options.headers.steroidsAppId
          cache:
            enabled: false
        }).findAll().should.be.fulfilled

      it "should retain default headers even after setting new ones", ->
        @timeout 5000
        # The call to findAll _should_ fail in case this overrides all default headers,
        # ie. steroidsApiKey is left out of the request
        supersonic.data.model('SandboxTask', {
          headers:
            steroidsAppId: window.ag.data.options.headers.steroidsAppId
          cache:
            enabled: false
        }).findAll().should.be.fulfilled
