noflo = require 'noflo'
unless noflo.isBrowser()
  fs = require 'fs'

getBuffer = (name, callback) ->
  fs.readFile name, (err, data) ->
    if err
      console.log 'ERROR: getBuffer():', err.message
      callback {}
    callback data

exports.getBuffer = getBuffer
