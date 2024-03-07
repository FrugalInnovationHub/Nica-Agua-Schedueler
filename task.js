const downloadFtp = require("./downloadFTP");
const downloadZip = require("./downloadZip");
const downloadIri = require("./downloadIri");
const runRScript = require("./runR");
const putLongTermForecasts = require("./postSeasonal");
const putShortTermForecasts = require("./postShortTerm");
const logActivity = require("./fileLog");
const fileLog = require("./fileLog");
const { exec } = require('child_process');

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
        logActivity("SHUTTING DOWN", "Shutting this machine down.");
        exec("sudo shutdown now -h");
    } catch (error) {
        logActivity("ERROR", `Task failed: ${error}`);
    }
}


fileLog("GIT","Fetching the latest version from github.");
exec("git pull",(err) => {
    if(err) fileLog("GIT ERR",err);
    main();
});
