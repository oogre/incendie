"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _dgram = _interopRequireDefault(require("dgram"));
var _dotenv = _interopRequireDefault(require("dotenv"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
_dotenv.default.config();
const server = _dgram.default.createSocket('udp4');
const IP = process.env.BULB_IP;
const PORT = parseInt(process.env.BULB_OUT_PORT);
const INPORT = parseInt(process.env.BULB_IN_PORT);
server.bind(INPORT, () => {
  server.setBroadcast(true);
});
const BULBS = async () => {
  let promise;
  return {
    send: async buffer => {
      if (promise != undefined) {
        console.log("blocked");
        return;
      }
      promise = new Promise((resolve, reject) => {
        server.send(buffer, 0, buffer.length, PORT, IP, function (err) {
          promise = undefined;
          if (err) reject(err);else resolve();
        });
      });
      return promise;
    }
  };
};
var _default = exports.default = BULBS();