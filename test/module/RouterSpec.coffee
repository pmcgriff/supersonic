chai = require('chai')
chai.should()

steroids = require '../../src/supersonic/mock/steroids'
Window = require '../../src/supersonic/mock/window'
logger = require('../../src/supersonic/core/logger')(steroids, new Window())

router = (routes = {}, global = new Window) ->
  env = modules: { routes }
  require('../../src/supersonic/core/module/router')(logger, env, global)

describe 'supersonic.module.router', ->
  it 'is an object', ->
    router().should.be.an 'object'

  describe 'getPath()', ->
    it 'is a function', ->
      router().should.have.property('getPath').be.a 'function'

    it 'requires a string', ->
      (-> router().getPath()).should.throw Error

    it 'returns a path to a module view when given a route', ->
      router().getPath('foo').should.match /\/foo\//

    it 'appends an object as query parameters', ->
      router().getPath('foo', bar: 'qux').should.match /\?bar=qux/

  describe 'route', ->
    it 'may have query parameters', ->
      router().getPath('foo?bar=qux').should.match /\?bar=qux/

    it 'may be parametrized with a view name', ->
      router().getPath('foo#bar').should.match /foo\/bar/

    it 'may contain dashes, dots and alnum chars', ->
      router().getPath('foo-bar.qux123#trog.dor').should.match /foo\-bar\.qux123\/trog\.dor/

    describe 'without a module name', ->

      it 'directs to a view in the same base url', ->
        router({}, {
          location:
            href: "http://www.example.com/module1234/index.html"
            origin: "http://www.example.com"
        }).getPath("#show").should.match /\/module1234\/show\.html/

      it 'supports parameters', ->
        router({}, {
          location:
            href: "http://www.example.com/module1234/index.html"
            origin: "http://www.example.com"
        }).getPath("#show", {foo: "bar"}).should.match /\/module1234\/show\.html\?foo=bar/


    describe 'view name', ->
      it 'defaults to "index"', ->
        router().getPath('foo').should.match /foo\/index/

      it 'has a default suffix of ".html"', ->
        router().getPath('foo').should.match /index\.html/

  describe 'root path', ->
    it 'defaults to /modules', ->
      router().getPath('foo').should.match /^\/modules/

  describe 'environment', ->
    it 'may define explicit targets for routes', ->
      router(
        foo:
          views:
            index:
              path: "path/to/route"
      ).getPath("foo").should.equal "path/to/route"

    describe 'explicit route target', ->
      it 'may have required params', ->
        (-> router(
          foo:
            views:
              index:
                path: "path/to/route"
                params:
                  id:
                    required: true
        ).getPath("foo")).should.throw Error

        router(
          foo:
            views:
              index:
                path: "path/to/route"
                params:
                  id:
                    required: true
        ).getPath("foo", id: 123).should.equal "path/to/route?id=123"

      it 'may be parametrized with :tokens', ->
        router(
          foo:
            views:
              index:
                path: "path/to/item/:id"
                params:
                  id:
                    required: true
        ).getPath("foo", id: 123).should.equal "path/to/item/123"
