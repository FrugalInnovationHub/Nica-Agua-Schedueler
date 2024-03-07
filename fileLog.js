const fs = require("fs");
const logFile = fs.createWriteStream(__dirname + '/debug.log', {flags : 'a'});

const logMessage = (action, message) => {
    const date = new Date().toUTCString();
    logFile.write(`${date} : (${action}) ${message} \n`);
    console.log(`\x1b[36m (${action}) \x1b[0m ${message}`);
};

module.exports = logMessage;
