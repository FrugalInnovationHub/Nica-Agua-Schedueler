const fs = require("fs");
var Client = require("ftp");

var c = new Client();
files = require("./folders.json");
fileLog = require("./fileLog");


function donwloadFtp(){
    function listFilesAssync(path) {
    return new Promise((resolve, reject) => {
        c.list(path.source, function (err, list) {
        if (err) reject(err);
        last = list.sort((a, b) => b.date - a.date)[0];
        last = {
            ...last,
            source: `${path.source}`,
            destination: `${path.destination}`,
        };
        return download(last.source,last.name,last.destination).then(() => resolve());
        });
    });
    }

    function download(source, name, destination) {
        return new Promise((resolve, reject) => {
            c.get(`${source}/${name}`, function (err, stream) {
            fileLog("Downloading", `${source}/${name}`);
            if (err) throw err;
            stream.once("close", function () {});
            stream.pipe(fs.createWriteStream(`${destination}`));
            resolve();
            });
        });
    }

    c.on("ready", function () {
    fileLog("Connection", "FTP Connection Stablished");
    var promises = files.shortTerm.files.map(listFilesAssync);
    Promise.all(promises).then(() => {
        c.end();
    });
    });

    

    return new Promise((resolve,reject) => {
        c.connect({ host: files.shortTerm.host });

        c.on("close",function(){
            fileLog("Connection", "FTP Connection Closed");
            resolve();
        })
    });
}

module.exports = donwloadFtp;

