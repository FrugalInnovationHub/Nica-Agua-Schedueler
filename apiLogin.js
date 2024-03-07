var request = require("request");
const url = "https://api.nicaagua.net";
const filelog = require("./fileLog");

function login() {
    filelog("API", "LOGIN");
    var options = {
      method: "POST",
      url: `${url}/user/login`,
      body: JSON.stringify({ phoneNumber: "7", password: "123" }),
      headers: {
        "Content-Type": "application/json",
      },
    };
  
    return new Promise((resolve, reject) => {
      request(options, function (error, response) {
        if(response.statusCode != 200 || error)
          reject("error");
        else {
          filelog("API", "LOGIN SUCCESS");
          resolve(response.body);
        }
      });
    });
  }

  module.exports = login;