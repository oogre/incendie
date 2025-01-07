"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _dotenv = _interopRequireDefault(require("dotenv"));
var _index = _interopRequireDefault(require("../DB/index.js"));
var _ws = require("ws");
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
const {
  WS_BULB
} = _dotenv.default.config().parsed;
const eventHandlers = {
  bulbs: []
};
let clients = [];
const BulbSocket = async () => {
  const db = await _index.default;
  const sockserver = new _ws.WebSocketServer({
    port: WS_BULB
  });
  sockserver.on('connection', async ws => {
    console.log('New BULB client connected!');
    ws.on('message', async data => {
      if (!Buffer.isBuffer(data) || data.length != 6) return;
      const [flamme] = await db.Flamme.find(data);
      if (!flamme) return;
      clients.push({
        unique_id: flamme.unique_id,
        wsc: ws
      });
    });
    ws.on('close', () => console.log('Client has disconnected!'));
    ws.onerror = function () {
      console.log('websocket error');
    };
  });
  return {
    send: async buffer => {
      clients = await clients.filter(async ({
        unique_id,
        wsc
      }) => {
        if (wsc.readyState === WebSocket.OPEN && unique_id < buffer.length) {
          await wsc.send(buffer[unique_id], {
            binary: true
          });
          return true;
        }
        return false;
      });
    }
  };
};
var _default = exports.default = BulbSocket();