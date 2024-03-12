/*----------------------------------------*\
  Brasseurs - DB.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 22:55:54
  @Last Modified time: 2024-03-12 13:47:48
\*----------------------------------------*/
import fs from 'fs';
import util from 'util';
import 'array.prototype.move';  
import crypto from'crypto';
import dotenv from 'dotenv';

const {ACCESS_SECRET} = dotenv.config().parsed;

const readFile = util.promisify(fs.readFile);
const appendFile = util.promisify(fs.appendFile);
const writeFile = util.promisify(fs.writeFile);


const RECORD_UNKNOWN_ADDRESS = true;

const WriteFile = async ({file}, content)=>{
	if(Array.isArray(content)){
		content = content.join("\n");
	}
	return writeFile(file, content, 'utf8');
}

const ReadFile = async ({file})=>{
	const content = (await readFile(file, 'utf8'))||"";
	return content.split("\n");
}

export default class DB{
	constructor(){
		this.tables = [{
			name : "Access",
			file : "./data/users.db",
			actions : (self) => {
				const toHash = (user, pwd) =>{
					return crypto.createHmac('sha256', ACCESS_SECRET).update(`${user} ${pwd}`).digest('hex');
				}
				const getAccess = async (user, pwd) => {
					const hash = toHash(user, pwd);
					const list = await this.list(self);
					const regexp = new RegExp(`${hash} (\\d+)`, "g");
					const [key, role=-1] = (list.find(elem => elem.match(regexp))||"").split(" ");
					return role;
				}
				return {
					getAccess,
					insert : async (user, pwd, role) => {
						const _role = await getAccess(user, pwd)
						if(_role == -1){
							const hash = toHash(user, pwd);
							return this.insert(self, hash+" "+role);
						}
						return _role;
					}
				}
			}
		},{
			name : "MacAddress",
			file : "./data/flames_mac_address.db",
			actions : (self) => {
				return {
					indexOf : async (MAC_ADDRESS) => {
						let {id} = await this.indexOf(self, MAC_ADDRESS);;
						if(RECORD_UNKNOWN_ADDRESS && id == -1){
							id = await this.insert(self, MAC_ADDRESS);
						}
						return id;
					},
					list : async () => {
						return this.list(self);
					},
					record : async (MAC_ADDRESS) => {
						return this.insert(self, MAC_ADDRESS);
					},
					move : async (MAC_ADDRESS, newId) => {
						let {id:oldId, length} = await this.indexOf(self, MAC_ADDRESS);;
						if(oldId == -1)return;
						newId = Math.min(newId, length-1);
						list.move(oldId, newId);
						await WriteFile(self, list);
					}
				}
			}
		}];
	}
	async list(table){
		return ReadFile(table);
	}
	async insert(table, value){
		await appendFile(table.file, value+"\n");
		return this.list(table).length-1;
	}
	async indexOf(table, value){
		const list = await this.list(self);
		return {id : list.findIndex(line=>line == value), length : list.length};
	}
	async remove(table, value){
		const list = await this.list(self);
		list.splice(list.indexOf(value), 1);
		await WriteFile(table, list)
	}
	listTables(){
		return this.tables.map(({name}) => name);
	}
	select(value){
		const table = this.tables.find(({name})=>value == name);
		return table.actions(table);
	}
}