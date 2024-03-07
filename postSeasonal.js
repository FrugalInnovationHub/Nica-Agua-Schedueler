const reader = require("xlsx");
const moment = require("moment");
const request = require("request");
const logActivity = require("./fileLog");
const apiLogin = require("./apiLogin");
const apiUrl = "https://api.nicaagua.net";

class SeasonalForecast {
  constructor(data, quarter) {
    this.community = data["Community"];
    this.wet = data[`probWet${quarter}`];
    this.dry = data[`probDry${quarter}`];
    this.text = data[`LT${quarter}${quarter+2}`];
    this.startDate = moment(new Date())
        .add(quarter - 1, "months")
        .format("YYYY-MM-DD");
    this.endDate = moment(new Date())
        .add(quarter + 2, "months")
        .format("YYYY-MM-DD");
  }
}

const readSpreadSheet = async () => {
  logActivity("EXCEL", "READING FILES");
  const file = reader.readFile("./Data/seasonal.xlsx");
  let data = [];
  const sheets = file.SheetNames;
  for (let i = 0; i < sheets.length; i++) {
    const temp = reader.utils.sheet_to_json(file.Sheets[file.SheetNames[i]]);
    data = temp.map((res) => res);
  }
  data = data.map((e) => [1, 2, 3, 4].map((i) => new SeasonalForecast(e, i))).flat(1);
  return JSON.stringify({ forecasts: data });
}

const putLongTermForecasts = async () => {
  logActivity("API","START SEASONAL FORECAST");
  try {
    const data = await readSpreadSheet();
    const token = await apiLogin();
    logActivity("API", "PUTTING DATA");
    const options = {
      method: "PUT",
      url: `${apiUrl}/longTerm`,
      body: data,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    };
    request(options, function (error, response) {
      if (error) throw error;
      logActivity("API","FINISH SEASONAL FORECAST");
    });
  } catch (error) {
    logActivity("API", "ERROR");
    console.error(`Error: ${error}`);
  }
}

module.exports = putLongTermForecasts;
