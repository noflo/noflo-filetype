noflo = require 'noflo'
unless noflo.isBrowser()
  chai = require 'chai' unless chai
  testutils = require './testutils'
  path = require 'path'
  baseDir = path.resolve __dirname, '../'

describe 'DetectFiletype component', ->
  c = null
  ins = null
  out = null
  err = null
  before (done) ->
    loader = new noflo.ComponentLoader baseDir
    loader.load 'filetype/DetectFiletype', (err, instance) ->
      return done err if err
      c = instance
      ins = noflo.internalSocket.createSocket()
      c.inPorts.in.attach ins
      done()
  beforeEach ->
    out = noflo.internalSocket.createSocket()
    err = noflo.internalSocket.createSocket()
    c.outPorts.out.attach out
    c.outPorts.error.attach err
  afterEach ->
    c.outPorts.out.detach out
    c.outPorts.error.detach err

  describe 'when instantiated', ->
    it 'should have an input port', ->
      chai.expect(c.inPorts.in).to.be.an 'object'
    it 'should have an output port', ->
      chai.expect(c.outPorts.out).to.be.an 'object'
    it 'should have an error port', ->
      chai.expect(c.outPorts.error).to.be.an 'object'

  describe 'when passed an image buffer', ->
    @timeout 5000
    describe 'of a JPG file', ->
      it 'should detect it has a JPG file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/jpeg'
          done()
        testutils.getBuffer __dirname + '/fixtures/file.jpg', (buffer) ->
          ins.send buffer
    describe 'of a PNG file', ->
      it 'should detect it has a PNG file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/png'
          done()
        testutils.getBuffer __dirname + '/fixtures/file.png', (buffer) ->
          ins.send buffer
    describe 'of a GIF file', ->
      it 'should detect it has a GIF file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/gif'
          done()
        testutils.getBuffer __dirname + '/fixtures/file.gif', (buffer) ->
          ins.send buffer
    describe 'of a TIFF file', ->
      it 'should detect it has a TIFF file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/tiff'
          done()
        testutils.getBuffer __dirname + '/fixtures/file.tif', (buffer) ->
          ins.send buffer
    describe 'of a SVG file', ->
      it 'should detect it has a SVG file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/svg+xml'
          done()
        testutils.getBuffer __dirname + '/fixtures/file.svg', (buffer) ->
          ins.send buffer
    describe 'of a WEBP file', ->
      it 'should detect it has a WEBP file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/webp'
          done()
        testutils.getBuffer __dirname + '/fixtures/file.webp', (buffer) ->
          ins.send buffer

    describe 'of a file without extension', ->
      it 'should detect it has a valid file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/gif'
          done()
        testutils.getBuffer __dirname + '/fixtures/file', (buffer) ->
          ins.send buffer
    describe 'of a file with unsupported file type', ->
      it 'should fail with a valid error', (done) ->
        err.on 'data', (data) ->
          chai.expect(data).to.be.an 'error'
          chai.expect(data.message).to.equal 'Unsupported file type'
          done()
        testutils.getBuffer __dirname + '/testutils.coffee', (buffer) ->
          ins.send buffer

  describe 'when passed a filepath', ->
    @timeout 5000
    describe 'of a JPG file', ->
      it 'should detect it has a JPG file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/jpeg'
          done()
        ins.send __dirname + '/fixtures/file.jpg'
    describe 'of a PNG file', ->
      it 'should detect it has a PNG file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/png'
          done()
        ins.send __dirname + '/fixtures/file.png'
    describe 'of a GIF file', ->
      it 'should detect it has a GIF file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/gif'
          done()
        ins.send __dirname + '/fixtures/file.gif'
    describe 'of a TIFF file', ->
      it 'should detect it has a TIFF file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/tiff'
          done()
        ins.send __dirname + '/fixtures/file.tif'
    describe 'of a SVG file', ->
      it 'should detect it has a SVG file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/svg+xml'
          done()
        ins.send __dirname + '/fixtures/file.svg'
    describe 'of a WEBP file', ->
      it 'should detect it has a WEBP file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/webp'
          done()
        ins.send __dirname + '/fixtures/file.webp'

    describe 'of a file without extension', ->
      it 'should detect it has a valid file type', (done) ->
        out.on 'data', (data) ->
          chai.expect(data).to.be.equal 'image/gif'
          done()
        ins.send __dirname + '/fixtures/file'
    describe 'of a file with unsupported file type', ->
      it 'should fail with a valid error', (done) ->
        err.on 'data', (data) ->
          chai.expect(data).to.be.an 'error'
          chai.expect(data.message).to.equal 'Unsupported file type'
          done()
        ins.send __dirname + '/testutils.coffee'

  describe 'when passed neither a buffer nor filepath', ->
    it 'should fail with a valid error', (done) ->
      err.on 'data', (data) ->
        chai.expect(data).to.be.an 'error'
        chai.expect(data.message).to.equal 'Input is not filepath nor buffer'
        done()
      ins.send 42


