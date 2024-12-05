"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _dotenv = _interopRequireDefault(require("dotenv"));
var _express = _interopRequireDefault(require("express"));
var _path = _interopRequireDefault(require("path"));
var _index = _interopRequireDefault(require("../DB/index.js"));
function _interopRequireDefault(e) { return e && e.__esModule ? e : { default: e }; }
const {
  API_PORT
} = _dotenv.default.config().parsed;
const API = async () => {
  const db = await _index.default;
  const app = (0, _express.default)();
  app.use(_express.default.json());
  app.listen(API_PORT, () => {
    console.log("Server Listening on PORT:", API_PORT);
  });
  app.get(`/status`, (request, response) => {
    const status = {
      Status: `Running`
    };
    response.send(status);
  });
  app.get('/flammes', async (request, response) => {
    const flammes = await db.Flamme.all();
    response.send(flammes);
  });
  app.post('/flamme', async (request, response) => {
    const MacAddress = request.body?.MacAddress;
    if (!MacAddress) response.send(`error`);
    const MAC_ADDRESS = Buffer.from(Uint8Array.from(MacAddress));
    const flamme = await db.Flamme.create(MAC_ADDRESS);
    response.send(`flamme id : ${flamme.unique_id - 1}`);
  });
  app.post(`/setPosition`, async (request, response) => {
    const MacAddress = request.body?.MacAddress;
    const position = request.body?.position;
    const flamme = await db.Flamme.move(MacAddress, position);
    response.send(flamme);
  });
};
var _default = exports.default = API();