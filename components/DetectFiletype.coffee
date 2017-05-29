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

  c.process (input, output) ->
    return unless input.hasData 'in'
    data = input.getData 'in'

    if Buffer.isBuffer data
      chunk = if data.length >= 262 then data.slice 0, 262 else data
      type = fileType chunk
      unless type
        if isSVG chunk
          output.sendDone
            out:'image/svg+xml'
          return
        return output.done new Error 'Unsupported file type'
      output.sendDone
        out: type.mime
      return
    else if typeof data is 'string'
      readChunk data, 0, 262
      .then (buffer) ->
        type = fileType buffer
        unless type
          if isSVG buffer
            output.sendDone
              out: 'image/svg+xml'
            return
          return output.done new Error 'Unsupported file type'
        output.sendDone
          out: type.mime
        return
      .catch (error) ->
        output.done new Error 'Cannot read file'
    else
      return output.done new Error 'Input is not filepath nor buffer'
