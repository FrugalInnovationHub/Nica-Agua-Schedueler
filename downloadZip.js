files = require("./folders.json");
fileLog = require("./fileLog");
const gunzip = require('gunzip-file')
const fs = require("fs");
const http = require('http'); // or 'https' for https:// URLs

function downloadData(){
    return new Promise((resolve,reject) => {
    fileLog("Downloading",files.longTerm.source);
    const file = fs.createWriteStream(`${__dirname}/${files.longTerm.destination}`);
    http.get(files.longTerm.source, 
    function(response) {
      response.pipe(file);
      // after download completed close filestream
      file.on("finish", () => {
          file.close();
          fileLog("ZIP",`Start Unziping ${files.longTerm.destination}`)
          gunzip(`${__dirname}/${files.longTerm.destination}`, `${__dirname}/${files.longTerm.destination}`.slice(0, -3), () => {
          fileLog("ZIP",`Done Unziping ${__dirname}/${files.longTerm.destination}`)
          fileLog("FILE",`Deleting ${__dirname}/${files.longTerm.destination}`)
          fs.unlinkSync(`${__dirname}/${files.longTerm.destination}`)
          fileLog("DONE","")
          resolve();
          })
      });
    });
  });
}

module.exports = downloadData;