import UDP from 'dgram';
import dotenv from 'dotenv';
dotenv.config();

const server = UDP.createSocket('udp4')

const IP = process.env.BULB_IP;
const PORT = parseInt(process.env.BULB_OUT_PORT);


const delay = (duration) => {
  return new Promise(function(resolve, reject){
    setTimeout(function(){
      resolve();
    }, duration)
  });
};

const BULBS = async () => {
	let promise;
	return {
		send : async (buffer)=>{
			if(promise != undefined){
				console.log("blocked");
				return;
			}
  			promise = new Promise ((resolve, reject)=>{
    			server.send(buffer, PORT, IP, async (err) => {
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