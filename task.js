const downloadFtp = require("./downloadFTP");
const downloadZip = require("./downloadZip");
const downloadIri = require("./downloadIri");
const runRScript = require("./runR");
const putLongTermForecasts = require("./postSeasonal");
const putShortTermForecasts = require("./postShortTerm");
const logActivity = require("./fileLog");

async function main() {
    try {
        await downloadFtp();
        await downloadZip();
        await downloadIri();
        await runRScript();
        await putLongTermForecasts();
        await putShortTermForecasts();
        logActivity("DONE", "All tasks completed");
    } catch (error) {
        logActivity("ERROR", `Task failed: ${error}`);
    }
}

main().catch(error => console.error(error));
