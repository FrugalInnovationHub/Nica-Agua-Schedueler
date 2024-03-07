var fileLog = require('./fileLog')
var CronJob = require('cron').CronJob;
let task = require('./task')
var job = new CronJob(
	'0 0 3 * * *',
	function() {
        fileLog("Schedueler","Starting Task");
		task().catch(error => console.error(error));
	},
	function () {
		fileLog("Schedueler","End of Task");
	},
	true,
	'America/Los_Angeles'
);