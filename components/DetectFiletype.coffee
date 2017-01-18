noflo = require 'noflo'
fileType = require 'file-type'
readChunk = require 'read-chunk'

# @runtime noflo-nodejs

isSVG = (buffer) ->
  # Try poor parsing it to see if it's a SVG
  asString = buffer.toString()
  if asString.match '<svg'
    return true
  return false

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
    out: ['out']
    forwardGroups: true
    async: true
  , (data, groups, out, callback) ->
    if Buffer.isBuffer data
      chunk = if data.length >= 262 then data.slice 0, 262 else data
      type = fileType chunk
      unless type
        if isSVG chunk
          out.send 'image/svg+xml'
          do callback
          return
        return callback new Error 'Unsupported file type'
      out.send type.mime
      do callback
      return
    else if typeof data is 'string'
      readChunk data, 0, 262
      .then (buffer) ->
        type = fileType buffer
        unless type
          if isSVG buffer
            out.send 'image/svg+xml'
            do callback
            return
          return callback new Error 'Unsupported file type'
        out.send type.mime
        do callback
        return
      .catch (error) ->
        callback new Error 'Cannot read file'
    else
      return callback new Error 'Input is not filepath nor buffer'
