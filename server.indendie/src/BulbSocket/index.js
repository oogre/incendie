import dotenv from 'dotenv';
import DB from '../DB/index.js'
import { WebSocketServer } from 'ws'

const {
    WS_BULB,
    RECORD_BULB
} = dotenv.config().parsed;

const eventHandlers = {
	bulbs : []
}
let clients = [];



const BulbSocket = async () => {
	const db = await DB;
	const sockserver = new WebSocketServer	({ port: WS_BULB })
	sockserver.on('connection', async ws => {
		console.log('New BULB client connected!');
		ws.on('message', async data => {
			if(!Buffer.isBuffer(data) || data.length != 6)
				return;
			let [flamme] = await db.Flamme.find(data)
			if(!flamme){
				if(RECORD_BULB){
					const MAC_ADDRESS = Buffer.from(Uint8Array.from(data));
					flamme = await db.Flamme.create(MAC_ADDRESS);	
				}else{
					return;	
				}
			}

			clients.push({
				unique_id : flamme.unique_id,
				wsc : ws
			});
		});
		ws.on('close', () => console.log('Client has disconnected!'))
		ws.onerror = function () {
			console.log('websocket error')
		}
	});

	return {
		send : async (buffer)=>{
			clients = await clients.filter(async ({unique_id, wsc}) => {
				if(wsc.readyState === WebSocket.OPEN && unique_id < buffer.length){
					await wsc.send(buffer[unique_id], { binary: true });
					return true;	
				}
				return false;
			});
		},
		all : async (value)=>{
			clients.map(async (wsc)=>{
				wsc.send(Math.round(value), { binary: true });
			})
		}
	}
}

export default BulbSocket();

