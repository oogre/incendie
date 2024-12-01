import dotenv from 'dotenv';
import mongoose from 'mongoose';
import Flamme from './Flamme.js';

const {
    MONGO_DB, 
    DB_NAME
} = dotenv.config().parsed;

const DB = async ()=>{
	const db = await mongoose.connect(`${MONGO_DB}/${DB_NAME}`);
	const flammeHelper = Flamme(db);

	return {
		Flamme : flammeHelper
	};

}

export default DB();