#!/usr/local/bin/node

import DB from './DB/index.js'
import API from './API/index.js'
import WS from './WS/index.js'
import BULBS from './BULBS'



(async ()=>{
  const db = await DB;
  const api = await API;
  const ws = await WS;
  const bulbs = await BULBS;

  db.Flamme.onChange(flamme =>{
    ws.trigNewFlamme(flamme);
  });
  
  ws.onBulbs(async data => {
    await bulbs.send(data);
  });

  
})()
.then(()=>{})
.catch(()=>{})