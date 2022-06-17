const schedule = require("node-schedule");
const fileLog = require("./fileLog")
fileLog("Schedueler","Initializing Schedueler");

const job = schedule.scheduleJob("* */15 * * *", function () {
  fileLog("Schedueler","Starting Job");
  require('child_process').fork('./task.js');
});
