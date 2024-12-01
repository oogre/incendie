"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _fs = _interopRequireDefault(require("fs"));
var _util = _interopRequireDefault(require("util"));
require("array.prototype.move");
var _crypto = _interopRequireDefault(require("crypto"));
var _dotenv = _interopRequireDefault(require("dotenv"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
/*----------------------------------------*\
  Brasseurs - DB.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-11 22:55:54
  @Last Modified time: 2024-06-26 12:49:35
\*----------------------------------------*/

const {
  ACCESS_SECRET
} = _dotenv.default.config().parsed;
const readFile = _util.default.promisify(_fs.default.readFile);
const appendFile = _util.default.promisify(_fs.default.appendFile);
const writeFile = _util.default.promisify(_fs.default.writeFile);
const RECORD_UNKNOWN_ADDRESS = true;
const WriteFile = async ({
  file
}, content) => {
  if (Array.isArray(content)) {
    content = content.join("\n");
  }
  return writeFile(file, content, 'utf8');
};
const ReadFile = async ({
  file
}) => {
  const content = (await readFile(file, 'utf8')) || "";
  return content.split("\n");
};
class DB {
  constructor() {
    this.tables = [{
      name: "Access",
      file: "./data/users.db",
      actions: self => {
        const toHash = (user, pwd) => {
          return _crypto.default.createHmac('sha256', ACCESS_SECRET).update(`${user} ${pwd}`).digest('hex');
        };
        const getAccess = async (user, pwd) => {
          const hash = toHash(user, pwd);
          const list = await this.list(self);
          const regexp = new RegExp(`${hash} (\\d+)`, "g");
          const [key, role = -1] = (list.find(elem => elem.match(regexp)) || "").split(" ");
          return role;
        };
        return {
          getAccess,
          insert: async (user, pwd, role) => {
            const _role = await getAccess(user, pwd);
            if (_role == -1) {
              const hash = toHash(user, pwd);
              return this.insert(self, hash + " " + role);
            }
            return _role;
          }
        };
      }
    }, {
      name: "MacAddress",
      file: "./data/flames_mac_address.db",
      actions: self => {
        const getIndexOf = async value => {
          const list = await this.list(self);
          return {
            id: list.findIndex(line => line.startsWith(value)),
            length: list.length
          };
        };
        return {
          indexOf: async MAC_ADDRESS => {
            MAC_ADDRESS = MAC_ADDRESS.toString('hex');
            console.log(MAC_ADDRESS);
            let {
              id
            } = await getIndexOf(MAC_ADDRESS);
            ;
            console.log(id);
            if (RECORD_UNKNOWN_ADDRESS && id == -1) {
              id = await this.insert(self, [MAC_ADDRESS, 0, 0, 0].join(" "));
              console.log(id);
            }
            return id;
          },
          list: async () => {
            const list = await this.list(self);
            return list.filter(e => typeof e !== "string" || e.trim() !== "").map(e => {
              const [MAC_ADDRESS, x, y, z] = e.split(" ");
              return {
                MAC_ADDRESS,
                x: parseFloat(x),
                y: parseFloat(y),
                z: parseFloat(z)
              };
            });
          },
          record: async (MAC_ADDRESS, x = 0, y = 0, z = 0) => {
            MAC_ADDRESS = MAC_ADDRESS.toString('hex');
            return this.insert(self, [MAC_ADDRESS, x, y, z].join(" "));
          },
          setPosition: async (MAC_ADDRESS, x = 0, y = 0, z = 0) => {
            MAC_ADDRESS = MAC_ADDRESS.toString('hex');
            let {
              id
            } = await getIndexOf(MAC_ADDRESS);
            if (id == -1) return;
            const list = await this.list(self);
            list[id] = [MAC_ADDRESS, x, y, z].join(" ");
            await WriteFile(self, list);
            return id;
          },
          move: async (MAC_ADDRESS, newId) => {
            MAC_ADDRESS = MAC_ADDRESS.toString('hex');
            let {
              id: oldId,
              length
            } = await getIndexOf(MAC_ADDRESS);
            ;
            if (oldId == -1) return;
            newId = Math.min(newId, length - 1);
            const list = await this.list(self);
            list.move(oldId, newId);
            await WriteFile(self, list);
          }
        };
      }
    }];
  }
  async list(table) {
    return ReadFile(table);
  }
  async insert(table, value) {
    await appendFile(table.file, value + "\n");
    const {
      length
    } = await this.list(table);
    return length - 2;
  }
  async remove(table, value) {
    const list = await this.list(self);
    list.splice(list.indexOf(value), 1);
    await WriteFile(table, list);
  }
  listTables() {
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
var _default = exports.default = new DB(); //so it is a singleton