"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _dgram = _interopRequireDefault(require("dgram"));
var _dotenv = _interopRequireDefault(require("dotenv"));
function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }
/*----------------------------------------*\
  incendie - BulbsController.js
  @author Evrard Vincent (vincent@ogre.be)
  @Date:   2024-03-13 18:20:19
  @Last Modified time: 2024-03-17 14:16:12
\*----------------------------------------*/

const server = _dgram.default.createSocket('udp4');
const {
  BULB_IN_PORT,
  BULB_OUT_PORT
} = _dotenv.default.config().parsed;
const delay = duration => {
  return new Promise(function (resolve, reject) {
    setTimeout(function () {
      resolve();
    }, duration);
  });
};
const send = async buffer => {
  return new Promise((resolve, reject) => {
    server.send(buffer, parseInt(BULB_OUT_PORT), "192.168.1.255", err => {
      if (err) reject(err);else resolve();
    });
  });
};
class BulbsController {
  constructor({
    DB
  }, readyHandler = () => {}) {
    Promise.all([DB.select("MacAddress").list(), new Promise((resolve, reject) => {
      server.on('listening', () => {
        server.setBroadcast(true);
        const address = server.address();
        console.log(`Bulbs Server Ready : UDP Listening on ${BULB_IN_PORT} sending on ${BULB_OUT_PORT}`);
        resolve();
      });
      server.on('message', (message, info) => {
        console.log('Message', message.toString());
        const response = Buffer.from('Message Received');
      });
    })]).then(([bulbs]) => {
      return bulbs.length - 1;
    }).then(bulbsCount => {
      readyHandler();
      return bulbsCount;
    }).then(async bulbsCount => {
      const anim = Animator(bulbsCount);
      let t0 = Date.now();
      while (true) {
        const time = (Date.now() - t0) * 0.0003;
        await send(Buffer.from(anim.SINE(time)));
        await delay(20);
      }
    });
    server.bind(parseInt(BULB_IN_PORT));
  }
}
exports.default = BulbsController;
;
const Animator = bulbsCount => {
  const sigmoid = x => {
    return Math.exp(x) / (Math.exp(x) + 1);
  };
  return {
    SINE: time => {
      const alpha = time * Math.PI * 2;
      return new Array(bulbsCount).fill(0).map((_, k, {
        length
      }) => {
        const offset = k / length * 2 * Math.PI;
        return Math.floor(sigmoid(Math.sin(offset + alpha) * 6) * 255);
      });
    },
    SQUARE: time => {
      const pahse = Math.floor(time) % bulbsCount;
      return new Array(bulbsCount).fill(0).map((_, k, {
        length
      }) => {
        return (pahse == k) * 255;
      });
    }
  };
};