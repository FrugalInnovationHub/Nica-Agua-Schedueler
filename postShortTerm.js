const reader = require("xlsx");
const request = require("request");
const logActivity = require("./fileLog");
const apiLogin = require("./apiLogin");
const apiUrl = "https://api.nicaagua.net";

class ShortTermForecast {
  constructor(data) {
    this.community = data["Community"];
    this.fiveDays = data["FiveDayForecast"];
    this.fiveDaysMax = data["FiveDayMax"];
    this.fiveDaysMin = data["FiveDayMin"];
    this.tenDays = data["TenDayForecast"];
    this.tenDaysMax = data["TenDayMax"];
    this.tenDaysMin = data["TenDayMin"];
    this.fifteenDays = data["FifteenDayForecast"];
    this.fifteenDaysMax = data["FifteenDayMax"];
    this.fifteenDaysMin = data["FifteenDayMin"];
  }
}

const readSpreadSheet = async () => {
  logActivity("EXCEL", "READING FILES");
  const file = reader.readFile("./Data/stats.xlsx");
  let data = [];
  const sheets = file.SheetNames;
  for (let i = 0; i < sheets.length; i++) {
    const temp = reader.utils.sheet_to_json(file.Sheets[file.SheetNames[i]]);
    data = temp.map((res) => new ShortTermForecast(res));
  }
  return JSON.stringify({forecasts: data});
}

const putShortTermForecasts = async () => {
  logActivity("API", "START SHORT TERM FORECAST");
  process.env["NODE_TLS_REJECT_UNAUTHORIZED"] = 0;
  try {
    const data = await readSpreadSheet();
    const token = await apiLogin();
    logActivity("API", "PUTTING DATA SHORT TERM");
    const options = {
      method: "PUT",
      url: `${apiUrl}/shortTerm`,
      body: data,
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`,
      },
    };
    request(options, (error, response) => {
      if (error) throw error;
      logActivity("API", "SUCCESS");
    });
  } catch (error) {
    logActivity("API", "ERROR");
    console.error(`Error: ${error}`);
  }
}

module.exports = putShortTermForecasts;
