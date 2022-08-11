// Requiring the module
const reader = require("xlsx");
const moment = require("moment");
var request = require("request");
const filelog = require("./fileLog");
// Reading our test file

/**Class that describes the Seasonal Forecast object */
class seasonalForecast {
  /**
   * Construct a Seasonal forecast based on the lines in the spreadsheet
   * @param {*} e Line in the spreadsheet
   * @param {*} quarter Number of quarters to skip (1 to 4)
   */
  constructor(e, quarter) {
    this.community = e["Community"];
    this.wet = e[`probWet${quarter}`];
    this.dry = e[`probDry${quarter}`];
    this.startDate = moment(new Date())
      .add((quarter - 1) * 3, "months")
      .format("YYYY-MM-DD");
    this.endDate = moment(new Date())
      .add(quarter * 3, "months")
      .format("YYYY-MM-DD");
  }
}

function readSpreadSheet() {
  return new Promise((resolve, reject) => {
    filelog("EXCELL", "READING FILES");
    const file = reader.readFile("./Data/seasonal.xlsx");
    var data = [];
    const sheets = file.SheetNames;
    for (let i = 0; i < sheets.length; i++) {
      const temp = reader.utils.sheet_to_json(file.Sheets[file.SheetNames[i]]);
      data = temp.map((res) => res);
    }
    data = data
      .map((e) => [1, 2, 3, 4].map((i) => new seasonalForecast(e, i)))
      .flat(1);
    resolve(JSON.stringify({ forecasts: data }));
  });
}

function login() {
  process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;
  filelog("API", "LOGIN");
  var options = {
    method: "POST",
    url: "https://localhost:3000/user/login",
    body: JSON.stringify({ phoneNumber: "7", password: "123" }),
    headers: {
      "Content-Type": "application/json",
    },
  };

  return new Promise((resolve, reject) => {
    request(options, function (error, response) {
      if (error) reject(error);
      filelog("API", "LOGIN SUCCESS");
      resolve(response.body);
    });
  });
}

function putLongTermForecasts() {
  return new Promise((resolve, reject) => {
    return readSpreadSheet().then((data) => {
      login().then((token) => {
        filelog("API", "PUTING DATA");
        var options = {
          method: "PUT",
          url: "https://localhost:3000/longTerm",
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
      });
    });
  });
}

module.exports = putLongTermForecasts;
