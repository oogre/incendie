"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _dotenv = _interopRequireDefault(require("dotenv"));
var _mongoose = _interopRequireDefault(require("mongoose"));
var _Flamme = _interopRequireDefault(require("./Flamme.js"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
const {
  MONGO_DB,
  DB_NAME
} = _dotenv.default.config().parsed;
const DB = async () => {
  const db = await _mongoose.default.connect(`${MONGO_DB}/${DB_NAME}`);
  const flammeHelper = (0, _Flamme.default)(db);
  return {
    Flamme: flammeHelper
  };
};
var _default = exports.default = DB();