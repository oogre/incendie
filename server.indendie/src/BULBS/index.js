import UDP from 'dgram';
import dotenv from 'dotenv';
dotenv.config();

const server = UDP.createSocket('udp4')


const IP = process.env.BULB_IP;
const PORT = parseInt(process.env.BULB_OUT_PORT);
const INPORT = parseInt(process.env.BULB_IN_PORT);


server.bind(INPORT, ()=>{
	server.setBroadcast(true);	
});

const 	 = async () => {
	let promise;
	return {
		send : async (buffer)=>{
			if(promise != undefined){
				console.log("blocked");
				return;
			}
  			promise = new Promise ((resolve, reject)=>{
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

export default BULBS();