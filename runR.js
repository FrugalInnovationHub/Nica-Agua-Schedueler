// todo: run preprocessing script
// todo: rename preprocessing output
// todo: run forecasting script
const logActivity = require("./fileLog");
const { exec } = require("child_process");

const executeRScript = async (scriptName) => {
  return new Promise((resolve, reject) => {
    logActivity("RScript", "Starting R Script");
    exec(`Rscript ${scriptName}`, (error, stdout, stderr) => {
      if (error) {
        logActivity("Error", "RScript Error");
        reject(`error: ${error.message}`);
        return;
      }
      if (stderr) {
        logActivity("SUCCESS", "RScript Success");
        resolve(`stderr: ${stderr}`);
        return;
      }
      resolve(`stdout: ${stdout}`);
    });
  });
}

const runRScript = async () => {
  const scriptName = "Rscript4.R";

  try {
    const result = await executeRScript(scriptName);
    console.log(result);
  } catch (error) {
    console.error(`Error: ${error}`);
  }
}

module.exports = runRScript;
