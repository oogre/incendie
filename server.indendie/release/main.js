#!/usr/local/bin/node
"use strict";

var _index = _interopRequireDefault(require("./DB/index.js"));
var _index2 = _interopRequireDefault(require("./API/index.js"));
var _index3 = _interopRequireDefault(require("./WS/index.js"));
var _BULBS = _interopRequireDefault(require("./BULBS"));
var _BulbSocket = _interopRequireDefault(require("./BulbSocket"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
process.title = "incendie";
const delay = time => {
  return new Promise(r => {
    setTimeout(() => r(), time);
  });
};
(async () => {
  const db = await _index.default;
  const api = await _index2.default;
  const ws = await _index3.default;
  const bulbs = await _BULBS.default;
  const bulbSocket = await _BulbSocket.default;
  db.Flamme.onChange(flamme => {
    ws.trigNewFlamme(flamme);
  });
  ws.onBulbs(async data => {
    await bulbs.send(data);
    await bulbSocket.send(data);
  });
})().then(() => {}).catch(() => {});