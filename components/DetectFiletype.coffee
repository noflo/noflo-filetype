noflo = require 'noflo'
fileType = require 'file-type'

exports.getComponent = ->
  c = new noflo.Component

  c.icon = 'cog'

  c.description = 'Detect file type of a buffer checking its magic number'

  c.inPorts.add 'in',
    datatype: 'object'

  c.outPorts.add 'out',
    datatype: 'string'

  noflo.helpers.WirePattern c,
    in: 'in'
    out: 'out'
    forwardGroups: true
    async: true
  , (data, groups, out, callback) ->
    type = fileType data
    out.send type.mime
    do callback

  c
