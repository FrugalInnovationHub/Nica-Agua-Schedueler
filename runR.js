fileLog = require("./fileLog");
const { exec } = require("child_process");

function runRScript() {
  return new Promise((resolve, reject) => {
    exec("Rscript Rscript2.R", (error, stdout, stderr) => {
      if (error) {
        reject(`error: ${error.message}`);
      }
      if (stderr) {
        resolve(`stderr: ${stderr}`);
      }
      resolve(`stdout: ${stdout}`);
    });
  });
}

module.exports = runRScript;
