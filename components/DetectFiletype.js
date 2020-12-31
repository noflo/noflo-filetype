const noflo = require('noflo');
const fileType = require('file-type');
const readChunk = require('read-chunk');

// @runtime noflo-nodejs

const isSVG = function (buffer) {
  // Try poor parsing it to see if it's a SVG
  const asString = buffer.toString();
  if (asString.match('<svg')) {
    return true;
  }
  return false;
};

exports.getComponent = function () {
  const c = new noflo.Component();

  c.icon = 'cog';

  c.description = 'Detect MIME type of a filepath or buffer checking its magic number';

  c.inPorts.add('in',
    { datatype: 'object' });

  c.outPorts.add('out',
    { datatype: 'string' });
  c.outPorts.add('error', {
    datatype: 'object',
    required: false,
  });

  return c.process((input, output) => {
    let type;
    if (!input.hasData('in')) { return; }
    const data = input.getData('in');

    if (Buffer.isBuffer(data)) {
      const chunk = data.length >= 262 ? data.slice(0, 262) : data;
      type = fileType(chunk);
      if (!type) {
        if (isSVG(chunk)) {
          output.sendDone({ out: 'image/svg+xml' });
          return;
        }
        output.done(new Error('Unsupported file type'));
        return;
      }
      output.sendDone({ out: type.mime });
    } else if (typeof data === 'string') {
      readChunk(data, 0, 262)
        .then((buffer) => {
          type = fileType(buffer);
          if (!type) {
            if (isSVG(buffer)) {
              output.sendDone({ out: 'image/svg+xml' });
              return;
            }
            output.done(new Error('Unsupported file type'));
            return;
          }
          output.sendDone({ out: type.mime });
        })
        .catch(() => {
          output.done(new Error('Cannot read file'));
        });
      return;
    }
    output.done(new Error('Input is not filepath nor buffer'));
  });
};
