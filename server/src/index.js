#!/usr/local/bin/node
/*----------------------------------------*\
  incendie - index.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 20:50:13
  @Last Modified time: 2024-03-12 13:42:01
\*----------------------------------------*/

import API from "./API.js";
import DB from "./DB.js";
import dotenv from 'dotenv';

const db = new DB();
const api = new API({
    DB : db,
    getAccess : db.select("Access").getAccess
});

const {
    ADMIN_USER, ADMIN_PWD,
    BULB_USER, BULB_PWD
} = dotenv.config().parsed;

const users = [
    [ADMIN_USER, ADMIN_PWD, 100],
    [BULB_USER, BULB_PWD, 1]
];

users.forEach(async ([user, pwd, role]) => {
    if(-1 == await db.select("Access").getAccess(user, pwd)){
        await db.select("Access").insert(user, pwd, role);
    }
});






