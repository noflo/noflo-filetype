noflo = require 'noflo'
fileType = require 'file-type'
readChunk = require 'read-chunk'

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'cog'

  c.description = 'Detect MIME type of a filepath or buffer checking its magic number'

  c.inPorts.add 'in',
    datatype: 'object'

  c.outPorts.add 'out',
    datatype: 'string'
  c.outPorts.add 'error',
    datatype: 'object'
    required: false

  noflo.helpers.WirePattern c,
    in: 'in'
    out: ['out', 'error']
    forwardGroups: true
    async: true
  , (data, groups, outPorts, callback) ->
    if Buffer.isBuffer data
      chunk = if data.length >= 262 then data.slice 0, 262 else data
      type = fileType chunk
      unless type
        outPorts.error.send new Error 'Unsupported file type'
        do callback
        return
      outPorts.out.send type.mime
      do callback
      return
    else if typeof data is 'string'
      readChunk data, 0, 262, (error, buffer) ->
        if error
          outPorts.error.send new Error 'Cannot read file'
          do callback
          return
        type = fileType buffer
        unless type
          outPorts.error.send new Error 'Unsupported file type'
          do callback
          return
        outPorts.out.send type.mime
        do callback
        return
    else
      outPorts.error.send new Error 'Input is not filepath nor buffer'
      do callback
      return
