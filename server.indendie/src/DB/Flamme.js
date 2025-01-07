import {Schema, model} from 'mongoose';
import autiIncrement from 'mongoose-id-autoincrement';

const DEFAULT_MAC_ADDRESS = Buffer.from(new Uint8Array([0,0,0,0,0,0]));
const DEFAULT_POSITION = [0, 0, 0];

const eventHandlers = {
	saved : []
}

const Flamme = (db) => {
	autiIncrement.initialize(db);
	
	const flammeSchema = new Schema({
		unique_id: Number,
		MacAddress : Buffer,
		position : [ Number, Number, Number ] 
	});

	flammeSchema.post('save', flamme => {
  		eventHandlers.saved.forEach(async handler => await handler(flamme));
	});

	flammeSchema.plugin(autiIncrement.plugin,  {
		model: 'flamme', 
		field: 'unique_id', 
		unique: false
	});

	const Flamme = model('Flamme', flammeSchema);

	return {
		create : async (MacAddress=DEFAULT_MAC_ADDRESS , position=DEFAULT_POSITION) => {
			const flamme = await Flamme.find({ MacAddress });
			if(flamme.length!=0){
				console.log(`this flamme already exists`)
				return flamme[0];
			}
			const newFlamme = new Flamme({
				MacAddress,
				position
			});
			const savedFlamme = await newFlamme.save();
			console.log(`new Flamme ${savedFlamme}`);
			return savedFlamme;
		},
		all : async () => {
			return await Flamme.find({ });
		},
		find : async (MacAddress=DEFAULT_MAC_ADDRESS ) => {
			return await Flamme.find({ MacAddress });
		},
		move : async (MacAddress=DEFAULT_MAC_ADDRESS , position=DEFAULT_POSITION) => {
			await Flamme.findOneAndUpdate({ MacAddress }, { position });
			return await Flamme.find({ MacAddress });
		},
		clear : async () => {
			await Flamme.deleteMany({})
		},
		onChange : (handler) => {
			if(typeof handler !== 'function')return;
			eventHandlers.saved.push(handler);
		}
	};
}

export default Flamme;