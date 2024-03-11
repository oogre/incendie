#!/usr/local/bin/node
/*----------------------------------------*\
  incendie - index.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 20:50:13
  @Last Modified time: 2024-03-12 00:47:14
\*----------------------------------------*/

import API from "./API.js";
import DB from "./DB.js";

const db = new DB();
const api = new API({
    DB : new DB(),
    hasAccess : (user, pwd) => {
        if(user == "incendie" && pwd == "incendie")
            return 1;
        return -1;
    }
});

