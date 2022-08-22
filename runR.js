fileLog = require("./fileLog");
const { exec } = require("child_process");

function runRScript() {
  return new Promise((resolve, reject) => {
    fileLog("RScript","Starting R Script");
    exec("Rscript Rscript2.R", (error, stdout, stderr) => {
      if (error) {
        fileLog("Error","RScript Error");
        reject(`error: ${error.message}`);
      }
      if (stderr) {
        fileLog("SUCCESS","RScript Success");
        resolve(`stderr: ${stderr}`);
      }
      resolve(`stdout: ${stdout}`);
    });
  });
}

module.exports = runRScript;
