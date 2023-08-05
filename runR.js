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
  const preScriptName = "IRI_fcst_preprocess.R";
  const scriptName1 = "Rscript4.R";

  try {
    const preResult = await executeRScript(preScriptName);
    const result = await executeRScript(scriptName1);
    console.log(result);
  } catch (error) {
    console.error(`Error: ${error}`);
  }
}

module.exports = runRScript;
