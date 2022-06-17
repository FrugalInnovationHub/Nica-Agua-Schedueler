const downloadFtp = require("./downloadFTP");
const downloadZip = require("./downloadZip");
const runRScript = require("./runR");

downloadFtp().then(() => {
  downloadZip().then(() => {
    runRScript().then()
  });
});
