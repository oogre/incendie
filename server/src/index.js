#!/usr/local/bin/node
/*----------------------------------------*\
  incendie - index.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 20:50:13
  @Last Modified time: 2024-03-13 21:29:05
\*----------------------------------------*/

import API from "./API.js";
import DB from "./DB.js";
import dotenv from 'dotenv';
import WebServer from "./WebServer.js";
import BulbsController from "./BulbsController.js";

const api = new API({
    DB,
    port : 8000,
    getAccess : DB.select("Access").getAccess
});

const webServer = new WebServer({
    DB,
    port : 8080,
    getAccess : DB.select("Access").getAccess
});

// const bulbs = new BulbsController({
//     DB
// });

const {
    ADMIN_USER, ADMIN_PWD,
    BULB_USER, BULB_PWD
} = dotenv.config().parsed;

const users = [
    [ADMIN_USER, ADMIN_PWD, 100],
    [BULB_USER, BULB_PWD, 1]
];

users.forEach(async ([user, pwd, role]) => {
    if(-1 == await DB.select("Access").getAccess(user, pwd)){
        await DB.select("Access").insert(user, pwd, role);
    }
});






