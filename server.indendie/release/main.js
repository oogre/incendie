#!/usr/local/bin/node
"use strict";

var _index = _interopRequireDefault(require("./DB/index.js"));
var _index2 = _interopRequireDefault(require("./API/index.js"));
var _index3 = _interopRequireDefault(require("./WS/index.js"));
var _BULBS = _interopRequireDefault(require("./BULBS"));
var _Sounds = _interopRequireDefault(require("./Sounds"));
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
  //const api = await API;
  //const ws = await WS;
  //const bulbs = await BULBS;
  //const sounds = await SOUNDS;
  const bulbSocket = await _BulbSocket.default;

  // db.Flamme.onChange(flamme =>{
  //   ws.trigNewFlamme(flamme);
  // });

  // ws.onBulbs(async data => {
  //   await bulbs.send(data);
  //   await sounds.send(data);
  //   await bulbSocket.send(data);
  // });

  let t0 = new Date().getTime();
  const cycle = 1.0 / (1000 * 60 * 60);
  const millis = () => new Date().getTime() - t0;
  setInterval(() => {
    let offset = Math.sin(millis() * cycle * 11 * Math.PI * 2) * 5 + 5;
    let baseLum = Math.sin(millis() * cycle * Math.PI * 2) * 0.4 + 0.5 + lerp(-offset, offset, Math.random()) * 0.01;
    bulbSocket.all(baseLum * 255);
  }, 50);
})().then(() => {}).catch(() => {});