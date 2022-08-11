const downloadFtp = require("./downloadFTP");
const downloadZip = require("./downloadZip");
const runRScript = require("./runR");
const putLongTermForecasts = require("./postSeasonal");
const filelog = require("./fileLog");

downloadFtp().then(() => {
  downloadZip().then(() => {
    runRScript().then(() => {
      putLongTermForecasts()
        .then()
        .catch(() => {
          filelog("Error", "Error running R Script");
        }).catch((e) => filelog(e));
    });
  });
});
