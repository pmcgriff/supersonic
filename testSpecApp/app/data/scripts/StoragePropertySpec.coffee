
describe "supersonic.data.storage.property", ->

  propertyName = null

  beforeEach ->
    propertyName = "this-is-property-#{Math.random()}"

  afterEach ->
    supersonic.data.storage.property(propertyName).unset?()

  it "is a function", ->
    supersonic.data.storage.property.should.be.a 'function'

  it "accepts a name and returns a property with that name", ->
    supersonic.data.storage.property(propertyName)
      .should.have.property('name')
      .equal propertyName

  describe "get()", ->
    it "returns null by default", ->
      expect(
        supersonic.data.storage.property(propertyName)
          .get()
      ).to.not.exist

  describe "set()", ->
    it "changes value returned by get()", ->
      supersonic.data.storage.property(propertyName)
        .set('this-is-a-value')
        .get()
        .should.equal 'this-is-a-value'

    it "can accept an object", ->
      supersonic.data.storage.property(propertyName)
        .set({ foo: 'bar' })
        .get()
        .should.deep.equal { foo: 'bar' }

  describe "unset()", ->
    it "resets the value to null", ->
      expect(
        supersonic.data.storage.property(propertyName)
          .set('anything')
          .unset()
          .get()
      ).to.not.exist

  describe "data storage", ->
    it "is shared between instances with the same name", ->
      left = supersonic.data.storage.property(propertyName)
      right = supersonic.data.storage.property(propertyName)

      left.set('foobar')
      right.get().should.equal 'foobar'

    xit "is shared between web views", ->
      value = Math.random()
      supersonic.data.storage.property(propertyName).set(value)

      propertyInOtherView = new Promise((resolve) ->
        supersonic.data.channel(propertyName).subscribe resolve
      )
      supersonic.ui.views.find("data#storage/get-property-and-publish?channel=#{propertyName}&property=#{propertyName}").then (view) ->
        view.start().then ->
          propertyInOtherView.then (otherValue) ->
            view.stop()
            value.should.equal otherValue

  describe "values", ->
    it "is a stream", ->
      supersonic.data.storage.property(propertyName)
        .values
        .should.have.property('onValue')
        .be.a 'function'

    it "should carry a default value of null", ->
      new Promise((resolve) ->
        supersonic.data.storage.property(propertyName)
          .values
          .onValue resolve
      ).should.eventually.not.exist

    it "should get a new value when the property is set", ->
      new Promise((resolve) ->
        supersonic.data.storage.property(propertyName)
          .set('foobar')
          .values
          .onValue (v) ->
            resolve v
      ).should.eventually.equal 'foobar'

    it "is shared between instances with the same name", ->
      left = supersonic.data.storage.property(propertyName)
      right = supersonic.data.storage.property(propertyName)

      left.set('foobar')

      new Promise((resolve) ->
        right.values.onValue resolve
      ).should.eventually.equal 'foobar'

    it "is shared between web views", ->
      value = "this-is-value-#{Math.random()}"
      prop = supersonic.data.storage.property(propertyName)

      updatedProperty = new Promise((resolve) ->
        prop.values.skip(1).onValue resolve
      )

      supersonic.ui.views.find("data#storage/set-property?property=#{propertyName}&value=#{value}").then (view) ->
        view.start().then ->
          updatedProperty.then (otherValue) ->
            view.stop()
            otherValue.should.equal value


