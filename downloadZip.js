const ftpConfig = require("./folders.json");
const logActivity = require("./fileLog");
const gunzip = require('gunzip-file');
const fs = require("fs");
const http = require('http');

const downloadFile = (sourceUrl, destinationPath) => {
    return new Promise((resolve, reject) => {
        const fileStream = fs.createWriteStream(destinationPath);
        const request = http.get(sourceUrl, (response) => {
            response.pipe(fileStream);
            fileStream.on("finish", function() {
                resolve();
            });
            fileStream.on("error", function(error) {
                reject(error);
            });
        });
        request.on("error", function(error) {
            reject(error);
        });
    });
}

const unzipFile = (zipFilePath, unzippedFilePath) => {
    return new Promise((resolve, reject) => {
        gunzip(zipFilePath, unzippedFilePath, (error) => {
            if (error) {
                reject(error);
            } else {
                resolve();
            }
        });
    });
}

const deleteFile = (filePath) => {
    fs.unlinkSync(filePath);
}

const downloadAndUnzipData = async () => {
    const sourceUrl = ftpConfig.longTerm.source;
    const destinationPath = `${__dirname}/${ftpConfig.longTerm.destination}`;
    const unzippedFilePath = destinationPath.slice(0, -3);

    try {
        logActivity("Downloading", sourceUrl);
        await downloadFile(sourceUrl, destinationPath);

        logActivity("ZIP", `Start Unzipping ${destinationPath}`);
        await unzipFile(destinationPath, unzippedFilePath);

        logActivity("ZIP", `Done Unzipping ${destinationPath}`);
        logActivity("FILE", `Deleting ${destinationPath}`);

        deleteFile(destinationPath);

        logActivity("DONE", "");
    } catch (error) {
        console.error(`Error: ${error}`);
    }
}

module.exports = downloadAndUnzipData;
