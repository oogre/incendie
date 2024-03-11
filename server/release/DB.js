"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _fs = _interopRequireDefault(require("fs"));
var _util = _interopRequireDefault(require("util"));
require("array.prototype.move");
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
/*----------------------------------------*\
  Brasseurs - DB.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 22:55:54
  @Last Modified time: 2024-03-12 00:40:37
\*----------------------------------------*/

const readFile = _util.default.promisify(_fs.default.readFile);
const appendFile = _util.default.promisify(_fs.default.appendFile);
const writeFile = _util.default.promisify(_fs.default.writeFile);
const RECORD_UNKNOWN_ADDRESS = true;
class DB {
  constructor() {
    this.tables = [{
      name: "MacAddress",
      file: "./data/flames_mac_address.db",
      actions: self => {
        const MacAddressList = async () => {
          return (await readFile(self.file, 'utf8')).split("\n");
        };
        const Record = async value => {
          await appendFile(self.file, value + "\n");
          return MacAddressList().length - 1;
        };
        const Clear = async () => {
          return writeFile(self.file, "", 'utf8');
        };
        const WriteFile = async content => {
          return writeFile(self.file, content, 'utf8');
        };
        return {
          indexOf: async MAC_ADDRESS => {
            const list = await MacAddressList();
            let id = list.findIndex(line => line == MAC_ADDRESS);
            if (RECORD_UNKNOWN_ADDRESS && id == -1) {
              id = await Record(MAC_ADDRESS);
            }
            return id;
          },
          list: async () => {
            return await MacAddressList();
          },
          record: async value => {
            return await Record(value);
          },
          setIndexOf: async (MAC_ADDRESS, newId) => {
            const list = await MacAddressList();
            let oldId = list.findIndex(line => line == MAC_ADDRESS);
            if (oldId == -1) {
              list.push(MAC_ADDRESS);
              oldId = list.length - 1;
            }
            newId = Math.min(newId, list.length - 1);
            list.move(oldId, newId);
            await WriteFile(list.join("\n"));
          }
        };
      }
    }];
  }
  list() {
    return this.tables.map(({
      name
    }) => name);
  }
  select(value) {
    const table = this.tables.find(({
      name
    }) => value == name);
    return table.actions(table);
  }
}
exports.default = DB;