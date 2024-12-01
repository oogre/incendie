#!/usr/local/bin/node
"use strict";

var _index = _interopRequireDefault(require("./DB/index.js"));
var _index2 = _interopRequireDefault(require("./API/index.js"));
var _index3 = _interopRequireDefault(require("./WS/index.js"));
var _BULBS = _interopRequireDefault(require("./BULBS"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
(async () => {
  const db = await _index.default;
  const api = await _index2.default;
  const ws = await _index3.default;
  const bulbs = await _BULBS.default;
  db.Flamme.onChange(flamme => {
    ws.trigNewFlamme(flamme);
  });
  ws.onBulbs(async data => {
    await bulbs.send(data);
  });
})().then(() => {}).catch(() => {});