#!/usr/local/bin/node
/*----------------------------------------*\
  incendie - index.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 20:50:13
  @Last Modified time: 2024-03-12 13:42:01
\*----------------------------------------*/
"use strict";

var _API = _interopRequireDefault(require("./API.js"));
var _DB = _interopRequireDefault(require("./DB.js"));
var _dotenv = _interopRequireDefault(require("dotenv"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
const db = new _DB.default();
const api = new _API.default({
  DB: db,
  getAccess: db.select("Access").getAccess
});
const {
  ADMIN_USER,
  ADMIN_PWD,
  BULB_USER,
  BULB_PWD
} = _dotenv.default.config().parsed;
const users = [[ADMIN_USER, ADMIN_PWD, 100], [BULB_USER, BULB_PWD, 1]];
users.forEach(async ([user, pwd, role]) => {
  if (-1 == (await db.select("Access").getAccess(user, pwd))) {
    await db.select("Access").insert(user, pwd, role);
  }
});