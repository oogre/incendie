import UDP from 'dgram';
import dotenv from 'dotenv';
dotenv.config();

const server = UDP.createSocket('udp4')


const IP = process.env.SOUND_IP;
const PORT = parseInt(process.env.SOUND_OUT_PORT);
const INPORT = parseInt(process.env.SOUND_IN_PORT);


server.bind(INPORT, ()=>{
	server.setBroadcast(false);	
});

const SOUNDS = async () => {
	let promise;
	return {
		send : async (buffer)=>{
			if(promise != undefined){
				console.log("blocked");
				return;
			}
  			promise = new Promise ((resolve, reject)=>{
  			//	console.log(buffer)
					server.send(buffer, 0, buffer.length, PORT, IP, function(err) {
		        		promise = undefined;
						if (err) reject(err);
						else resolve();
		    		});
  			});
  			return promise;
		}
	}
}

export default SOUNDS();