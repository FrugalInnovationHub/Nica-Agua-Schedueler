const fs = require('fs');
const https = require('https');
const logActivity = require('./fileLog');
const ftpConfig = require("./folders.json");

const key = ftpConfig.iri.key;
const url = new URL(ftpConfig.iri.source);
const rawFile = ftpConfig.iri.destination;

const downloadFile = () => {
    return new Promise((resolve, reject) => {
        const options = {
            hostname: url.hostname,
            path: url.pathname,
            headers: {
                'Cookie': `__dlauth_id=${key}`
            }
        };

        https.get(options, (response) => {
            const writer = fs.createWriteStream(rawFile);
            response.pipe(writer);
            writer.on('finish', resolve);
            writer.on('error', reject);
        }).on('error', (error) => {
            reject(error);
        });
    });
}

const downloadAndProcessData = async () => {
    // Delete the old raw data file if it exists
    if (fs.existsSync(rawFile)) {
        logActivity("Removing", rawFile);
        fs.unlinkSync(rawFile);
    }

    // Download new data file
    try {
        logActivity("Downloading", url.href);
        await downloadFile();
        logActivity("Downloaded", rawFile);
    } catch (error) {
        logActivity("Download failed", rawFile);
        console.error(`Download error: ${error}`);
    }
}

module.exports = downloadAndProcessData;
