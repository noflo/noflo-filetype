noflo = require 'noflo'
fileType = require 'file-type'
readChunk = require 'read-chunk'

exports.getComponent = ->
  new noflo.Component
    icon: 'cog'
    description: 'Detect MIME type of a filepath or buffer checking its magic number'
    inPorts:
      in:
        datatype: 'object'
    outPorts:
      out:
        datatype: 'string'
      error:
        datatype: 'object'
    process: (input, output) ->
      return unless input.has 'in'
      data = input.getData 'in'
      return unless input.ip.type is 'data'

      if Buffer.isBuffer data
        type = fileType data
        unless type
          return output.sendDone new Error 'Unsupported file type'
        return output.sendDone out: type.mime
      else if typeof data is 'string'
        readChunk data, 0, 262, (error, buffer) ->
          if error
            return output.sendDone new Error 'Cannot read file'
          type = fileType buffer
          unless type
            return output.sendDone new Error 'Unsupported file type'
          return output.sendDone out: type.mime
      else
        return output.sendDone new Error 'Input is not filepath nor buffer'
