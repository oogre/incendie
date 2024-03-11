#!/usr/local/bin/node
/*----------------------------------------*\
  incendie - index.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 20:50:13
  @Last Modified time: 2024-03-12 00:44:09
\*----------------------------------------*/
"use strict";

var _API = _interopRequireDefault(require("./API.js"));
var _DB = _interopRequireDefault(require("./DB.js"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
const db = new _DB.default();
const api = new _API.default({
  DB: new _DB.default(),
  hasAccess: (user, pwd) => {
    if (user == "incendie" && pwd == "incendie") return 1;
    return -1;
  }
});
(async () => {
  console.log(await db.select("MacAddress").setIndexOf("hello", 0));
})();