const fs = require("fs");
const FTPClient = require("ftp");
const ftpConfig = require("./folders.json");
const logActivity = require("./fileLog");

const client = new FTPClient();

const getLatestFileFromList = (fileList) => {
    return fileList.sort((a, b) => b.date - a.date)[0];
}

const listFilesAsync = (pathConfig) => {
    return new Promise((resolve, reject) => {
        client.list(pathConfig.source, async (error, fileList) => {
            if (error) {
                return reject(error);
            }
            const latestFile = getLatestFileFromList(fileList);
            const fileInformation = {
                ...latestFile,
                source: `${pathConfig.source}`,
                destination: `${pathConfig.destination}`,
            };
            try {
                await downloadFile(fileInformation);
                resolve();
            } catch (error) {
                reject(error);
            }
        });
    });
}

const downloadFile = (fileInformation) => {
    return new Promise((resolve, reject) => {
        client.get(`${fileInformation.source}/${fileInformation.name}`, (error, stream) => {
            if (error) {
                return reject(error);
            }
            logActivity("Downloading", `${fileInformation.source}/${fileInformation.name}`);
            stream.once("close", () => {});
            stream.pipe(fs.createWriteStream(`${__dirname}/${fileInformation.destination}`));
            resolve();
        });
    });
}

const connectAndDownloadFiles = async () => {
    return new Promise((resolve, reject) => {
        client.on("ready", async () => {
            logActivity("Connection", "FTP Connection Established");
            const promises = ftpConfig.shortTerm.files.map(listFilesAsync);
            try {
                await Promise.all(promises);
                client.end();
                resolve();
            } catch (error) {
                reject(error);
            }
        });

        client.connect({ host: ftpConfig.shortTerm.host });

        client.on("close", () => {
            logActivity("Connection", "FTP Connection Closed");
            resolve();
        });
    });
}

const downloadFtpFiles = async () => {
    try {
        await connectAndDownloadFiles();
    } catch (error) {
        console.error(`Error: ${error}`);
    }
}

module.exports = downloadFtpFiles;
