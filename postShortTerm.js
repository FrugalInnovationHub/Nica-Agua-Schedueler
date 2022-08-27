// Requiring the module
const reader = require("xlsx");
const moment = require("moment");
var request = require("request");
const filelog = require("./fileLog");
const login = require("./apiLogin");
const url = "https://api.nicaagua.net";
// Reading our test file

/**Class that describes the Seasonal Forecast object */
class shortTermForecast {
  /**
   * Construct a Seasonal forecast based on the lines in the spreadsheet
   * @param {*} e Line in the spreadsheet
   * @param {*} quarter Number of quarters to skip (1 to 4)
   */
  constructor(e, quarter) {
    this.community = e["Community"];
    this.fiveDays = e["FiveDayForecast"];
    this.fiveDaysMax = e["FiveDayMax"];
    this.fiveDaysMin = e["FiveDayMin"];
    this.tenDays = e[`TenDayForecast`];
    this.tenDaysMax = e[`TenDayMax`];
    this.tenDaysMin = e[`TenDayMin`];
    this.fifteenDays = e["FifteenDayForecast"];
    this.fifteenDaysMax = e["FifteenDayMax"];
    this.fifteenDaysMin = e["FifteenDayMin"];
    
  }
}

function readSpreadSheet() {
  return new Promise((resolve, reject) => {
    filelog("EXCELL", "READING FILES");
    const file = reader.readFile("./Data/stats.xlsx");
    var data = [];
    const sheets = file.SheetNames;
    for (let i = 0; i < sheets.length; i++) {
      const temp = reader.utils.sheet_to_json(file.Sheets[file.SheetNames[i]]);
      data = temp.map((res) => res);
    }
    data = data.map((e) => new shortTermForecast(e));
    resolve(JSON.stringify({forecasts:data}));
  });
}

function putShortTermForecasts() {
  process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;
  return new Promise((resolve, reject) => {
    return readSpreadSheet().then((data) => {
      login()
        .then((token) => {
          filelog("API", "PUTING DATA");
          var options = {
            method: "PUT",
            url: `${url}/shortTerm`,
            body: data,
            headers: {
              "Content-Type": "application/json",
              Authorization: `Bearer ${token}`,
            },
          };
          request(options, function (error, response) {
            if (error) reject(error);
            filelog("API", "SUCCESS");
            resolve();
          });
        })
        .catch((e) => {
          filelog("API", "LOGIN ERROR");
        });
    });
  });
}

module.exports = putShortTermForecasts;
