const downloadFtp = require("./downloadFTP");
const downloadZip = require("./downloadZip");
const downloadIri = require("./downloadIri");
const runRScript = require("./runR");
const putLongTermForecasts = require("./postSeasonal");
const putShortTermForecasts = require("./postShortTerm");
const logActivity = require("./fileLog");
const fileLog = require("./fileLog");

async function main() {
    fileLog("TASK","Starting Task")
    try {
        await downloadFtp();
        // await downloadZip(); // Error Downloading Zip
        await downloadIri();
        await runRScript();
        await putLongTermForecasts();
        await putShortTermForecasts();
        logActivity("DONE", "All tasks completed");
    } catch (error) {
        logActivity("ERROR", `Task failed: ${error}`);
    }
}

module.exports = main;
