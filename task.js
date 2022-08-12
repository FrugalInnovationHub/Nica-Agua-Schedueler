const downloadFtp = require("./downloadFTP");
const downloadZip = require("./downloadZip");
const runRScript = require("./runR");
const putLongTermForecasts = require("./postSeasonal");
const filelog = require("./fileLog");

downloadFtp().then(() => {
  downloadZip().then(() => {
    runRScript().then((e) => {
      putLongTermForecasts();
    });
  });
});
