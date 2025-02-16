"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
/*----------------------------------------*\
  Brasseurs - WebServer.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-12 13:56:00
  @Last Modified time: 2024-03-29 09:15:04
\*----------------------------------------*/
const express = require('express');
const path = require('path');
const app = express();
class WebServer {
  constructor({
    host = '0.0.0.0',
    port = '8080',
    getAccess,
    DB
  }) {
    app.use(express.static(path.join(__dirname + "/../", 'public')));
    app.set('view engine', 'ejs');
    app.use(express.json());
    app.get('/list', async (req, res) => {
      let bulbs = await DB.select("MacAddress").list();
      bulbs = bulbs.filter(bulb => typeof bulb !== "string" || bulb.trim() !== "");
      res.render('listBulb', {
        bulbs: bulbs
      });
    });
    app.get('/listRaw', async (req, res) => {
      let bulbs = await DB.select("MacAddress").list();
      res.json({
        bulbs
      });
    });
    app.get('/setPosition', async (req, res) => {
      const {
        MAC_ADDRESS,
        x,
        y,
        z
      } = req.body;
      DB.select("MacAddress").setPosition(MAC_ADDRESS, x, y, z);
      res.json({
        status: "ok"
      });
    });
    app.post('/move', async (req, res) => {
      const {
        MAC_ADDRESS,
        newId
      } = req.body;
      await DB.select("MacAddress").move(MAC_ADDRESS, newId);
      let bulbs = await DB.select("MacAddress").list();
      bulbs = bulbs.filter(bulb => typeof bulb !== "string" || bulb.trim() !== "");
      res.status(200).json(bulbs);
    });
    app.listen(port, () => {
      console.log(`WEB Server Ready : HTTP Listening on ${port}`);
    });
  }
}
exports.default = WebServer;
;