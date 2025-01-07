#!/usr/local/bin/node
process.title = "incendie"

import DB from './DB/index.js'
import API from './API/index.js'
import WS from './WS/index.js'
import BULBS from './BULBS'
import BulbSocket from './BulbSocket'


const delay = (time)=>{
  return new Promise(r =>{
    setTimeout(()=>r(), time);
  });
}

(async ()=>{
  const db = await DB;
  const api = await API;
  const ws = await WS;
  const bulbs = await BULBS;
  const bulbSocket = await BulbSocket;

  db.Flamme.onChange(flamme =>{
    ws.trigNewFlamme(flamme);
  });
  
  ws.onBulbs(async data => {
    await bulbs.send(data);
    await bulbSocket.send(data);
  });

  
})()
.then(()=>{})
.catch(()=>{})