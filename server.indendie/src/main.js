#!/usr/local/bin/node

process.title = "incendie"

//import DB from './DB/index.js'
//import API from './API/index.js'
//import WS from './WS/index.js'
//import BULBS from './BULBS'
//import SOUNDS from './Sounds'
import BulbSocket from './BulbSocket'


const clamp = (a, min = 0, max = 1) => Math.min(max, Math.max(min, a));
const lerp = ( a, b, alpha ) => a + alpha * ( b - a );
const invlerp = (x, y, a) => clamp((a - x) / (y - x));

const delay = (time)=>{
  return new Promise(r =>{
    setTimeout(()=>r(), time);
  });
}

(async ()=>{
  //const db = await DB;
  //const api = await API;
  //const ws = await WS;
  //const bulbs = await BULBS;
  //const sounds = await SOUNDS;
  const bulbSocket = await BulbSocket;

  // db.Flamme.onChange(flamme =>{
  //   ws.trigNewFlamme(flamme);
  // });
  
  // ws.onBulbs(async data => {
  //   await bulbs.send(data);
  //   await sounds.send(data);
  //   await bulbSocket.send(data);
  // });


  let t0 = new Date().getTime();
  const cycle = 1.0/(1000 * 60 * 60);

  const millis = ()=> new Date().getTime() - t0;

  setInterval(()=>{
    bulbSocket.all((id)=>{
      let offset = Math.sin(id + millis() * cycle * 11 * Math.PI * 2) * 5 + 5;
      let baseLum = Math.sin(id + millis() * cycle * Math.PI * 2) * 0.4 + 0.5 + ( lerp(-offset, offset, Math.random())*0.01);
      return Math.floor(baseLum * 255);
    });
  }, 50);

})()
.then(()=>{})
.catch(()=>{})