const fs = require('fs');

const getBuffer = (name, callback) => fs.readFile(name, (err, data) => {
  if (err) {
    console.log('ERROR: getBuffer():', err.message);
    callback({});
  }
  callback(data);
});

exports.getBuffer = getBuffer;
