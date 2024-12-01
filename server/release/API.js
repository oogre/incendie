"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _http = _interopRequireDefault(require("http"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
/*----------------------------------------*\
  Brasseurs - API.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 20:51:33
  @Last Modified time: 2024-10-13 19:29:48
\*----------------------------------------*/

class API {
  constructor({
    host = '0.0.0.0',
    port = '8000',
    getAccess,
    DB
  }) {
    this.getAccess = getAccess;
    this.access_points = [{
      method: "POST",
      url: "/register",
      accessLvl: 1,
      action: async MAC_ADDRESS => {
        MAC_ADDRESS = Buffer.from(Uint8Array.from(MAC_ADDRESS));
        return {
          id: await DB.select("MacAddress").indexOf(MAC_ADDRESS)
        };
      }
    }, {
      method: "POST",
      url: "/move",
      accessLvl: 10,
      action: async ({
        MAC_ADDRESS,
        newId
      }) => {
        console.log(MAC_ADDRESS, newId);
        // MAC_ADDRESS = Buffer.from(Uint8Array.from(MAC_ADDRESS));
        return {
          id: await DB.select("MacAddress").indexOf(MAC_ADDRESS)
        };
      }
    }, {
      method: "POST",
      url: "/setPosition",
      accessLvl: 10,
      action: async ([MAC_ADDRESS, [x, y, z]]) => {
        return {
          id: await DB.select("MacAddress").setPosition(MAC_ADDRESS, x, y, z)
        };
      }
    }];
    this.server = _http.default.createServer(this.API_ENTRY_POINT.bind(this));
    this.server.listen(port, host, () => {
      console.log(`API Server Ready : HTTP Listening on ${port}`);
    });
  }
  API_ENTRY_POINT(req, res) {
    let body = "";
    req.on('data', chunk => {
      body += chunk;
    });
    req.on('end', async () => {
      console.log(body);
      if (!body) {
        res.writeHead(401);
        res.end();
        return;
      }
      const {
        PWD,
        USER,
        data
      } = JSON.parse(body);
      const accessLvl = await this.getAccess(USER, PWD);
      if (accessLvl < 0) {
        res.writeHead(401);
        res.end();
        return;
      }
      const {
        action
      } = this.access_points.find(({
        method,
        url,
        accessLvl: lvl
      }) => accessLvl >= lvl && method == req.method && url == req.url);
      if (!action) {
        res.writeHead(404);
        res.end();
        return;
      }
      try {
        res.writeHead(200);
        res.write(JSON.stringify({
          success: true,
          data: await action(data)
        }));
        res.end();
      } catch (error) {
        console.log(error);
        res.writeHead(500);
        res.end();
      }
    });
  }
}
exports.default = API;