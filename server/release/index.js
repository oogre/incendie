#!/usr/local/bin/node
/*----------------------------------------*\
  incendie - index.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 20:50:13
  @Last Modified time: 2024-03-19 23:53:37
\*----------------------------------------*/
"use strict";

var _API = _interopRequireDefault(require("./API.js"));
var _DB = _interopRequireDefault(require("./DB.js"));
var _dotenv = _interopRequireDefault(require("dotenv"));
var _WebServer = _interopRequireDefault(require("./WebServer.js"));
var _BulbsController = _interopRequireDefault(require("./BulbsController.js"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
const api = new _API.default({
  DB: _DB.default,
  port: 8000,
  getAccess: _DB.default.select("Access").getAccess
});
const webServer = new _WebServer.default({
  DB: _DB.default,
  port: 8080,
  getAccess: _DB.default.select("Access").getAccess
});
const {
  ADMIN_USER,
  ADMIN_PWD,
  BULB_USER,
  BULB_PWD
} = _dotenv.default.config().parsed;
const users = [[ADMIN_USER, ADMIN_PWD, 100], [BULB_USER, BULB_PWD, 1]];
users.forEach(async ([user, pwd, role]) => {
  if (-1 == (await _DB.default.select("Access").getAccess(user, pwd))) {
    await _DB.default.select("Access").insert(user, pwd, role);
  }
});