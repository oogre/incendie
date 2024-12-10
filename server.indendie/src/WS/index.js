import dotenv from 'dotenv';
import DB from '../DB/index.js'
import { WebSocketServer } from 'ws'

const {
    WS_GODOT
} = dotenv.config().parsed;

const eventHandlers = {
	bulbs : []
}

const WS = async () => {
	const db = await DB;
	const sockserver = new WebSocketServer({ port: WS_GODOT })
	sockserver.on('connection', async ws => {
		console.log('New client connected!');
		const flammes = await db.Flamme.all();
		flammes.map(flamme => {
			ws.send(JSON.stringify(flamme))
		});
		ws.on('message', data => {
			eventHandlers.bulbs.forEach(async handler => await handler(data));
		});
		ws.on('close', () => console.log('Client has disconnected!'))
		ws.onerror = function () {
			console.log('websocket error')
		}
	});
	console.log("The WebSocket server is running on port 8080");

	return {
		trigNewFlamme : flamme => {
			sockserver.clients.forEach(client => {
				client.send(JSON.stringify(flamme))
			});
		},
		onBulbs : (handler) => {
			if(typeof handler !== 'function')return;
			eventHandlers.bulbs.push(handler);
		}
	};
}

export default WS();

