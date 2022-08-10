const downloadFtp = require("./downloadFTP");
const downloadZip = require("./downloadZip");
const runRScript = require("./runR");
const filelog = require("./fileLog");

downloadFtp().then(() => {
    runRScript()
      .then()
      .catch(() => {
        filelog("Error", "Error running R Script");
      });
  });
