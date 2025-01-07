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
  WS_GODOT
} = _dotenv.default.config().parsed;
const eventHandlers = {
  bulbs: []
};
const WS = async () => {
  const db = await _index.default;
  const sockserver = new _ws.WebSocketServer({
    port: WS_GODOT
  });
  sockserver.on('connection', async ws => {
    console.log('New GODOT client connected!');
    const flammes = await db.Flamme.all();
    flammes.map(flamme => {
      ws.send(JSON.stringify(flamme));
    });
    ws.on('message', data => {
      eventHandlers.bulbs.forEach(async handler => await handler(data));
    });
    ws.on('close', () => console.log('Client has disconnected!'));
    ws.onerror = function () {
      console.log('websocket error');
    };
  });
  console.log("The WebSocket server is running on port 8080");
  return {
    trigNewFlamme: flamme => {
      sockserver.clients.forEach(client => {
        client.send(JSON.stringify(flamme));
      });
    },
    onBulbs: handler => {
      if (typeof handler !== 'function') return;
      eventHandlers.bulbs.push(handler);
    }
  };
};
var _default = exports.default = WS();