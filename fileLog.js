const fs = require("fs");
var log_file = fs.createWriteStream(__dirname + '/debug.log', {flags : 'a'});

fileLog = function(action, message) {
    date = new Date().toUTCString();
    log_file.write(`${date} : (${action}) ${message} \n`);
    console.log('\x1b[36m',`(${action})`,'\x1b[0m',`${message}`);
  };

  module.exports = fileLog;