const R = require("r-integration");
fileLog = require("./fileLog");

function runRScript() {
  return new Promise((resolve, reject) => {
    try {
      fileLog("RScript","Starting R Script")
      R.executeRScript("./Rscript2.R");
      fileLog("RScript","Done R Script")
      resolve();
    } catch (e) {
      fileLog("RScript","Error running R Script")
      reject();
    }
  });
}

module.exports = runRScript;