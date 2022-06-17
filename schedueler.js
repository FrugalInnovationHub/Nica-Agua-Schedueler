const schedule = require("node-schedule");
const task =require("./task")
const job = schedule.scheduleJob("15 21 * * *", function () {
  require('child_process').fork('./task.js');
});
