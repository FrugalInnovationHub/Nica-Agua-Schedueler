const fs = require('fs');
const https = require('https');
const logActivity = require('./fileLog');

const key = "733039b0e02ed5acf2d45931d7b7810daa8b90f5d2cc6981ffe381ece6ca757bfcf27c92e817f0a4d5ba3005be5f1ea3cd1e654e";
const url = new URL("https://iridl.ldeo.columbia.edu/SOURCES/.IRI/.FD/.NMME_Seasonal_Forecast/.Precipitation_ELR/.prob/data.nc");
const rawFile = "./Data/raw_data.nc";

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
