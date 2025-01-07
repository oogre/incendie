import dotenv from 'dotenv';
import express from 'express';
import path from 'path';
import DB from '../DB/index.js'

const {
    API_PORT
} = dotenv.config().parsed;

const API = async ()=>{
	const db = await DB;

	const app = express();

	app.use(express.json());

	app.listen(API_PORT, () => {
		console.log("Server Listening on PORT:", API_PORT);
	});

	app.get(`/status`, (request, response)=>{
		const status = {
			Status: `Running`
		};
		response.send(status);
	});

	app.get('/flammes', async(request, response) => {
		const flammes = await db.Flamme.all();
		response.send(flammes);
	});

	app.post('/flamme', async(request, response) => {
		const MacAddress = request.body?.MacAddress;
		console.log(MacAddress);
		if(!MacAddress)response.send(`error`);
		const MAC_ADDRESS = Buffer.from(Uint8Array.from(MacAddress));
		const flamme = await db.Flamme.create(MAC_ADDRESS);
		response.send(`flamme id : ${flamme.unique_id-1}`);
		console.log(`flamme id : ${flamme.unique_id-1}`)
	});

	app.post(`/setPosition`, async(request, response) => {
		const MacAddress = request.body?.MacAddress;
		const position = request.body?.position;
		const flamme = await db.Flamme.move(MacAddress, position);
		response.send(flamme);
	})
}

export default API();

