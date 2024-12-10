#ifndef WSHelper_h
#define WSHelper_h

#include <WebSocketsClient.h>
#include <Hash.h>
#include "Tools.h"
#include "secret.h"
#include "BaseLeaf.h"

class WSHelper : public BaseLeaf{
    Tools::ControlLumHandler ctrlLumHandler;
    Tools::DisconnectedHandler disconnectedHandler;
    int disconnectedBuffer = 5;
    WebSocketsClient webSocket;
    public :
        WSHelper()
        : BaseLeaf(){}

        virtual ~WSHelper(){
        }

        int begin(){
            webSocket.begin(TO_LITERAL(DEFAULT__SERVER), DEFAULT__WS__PORT, "/");
	        webSocket.onEvent([this](WStype_t type, uint8_t * payload, size_t length){
                switch(type) {
                    case WStype_DISCONNECTED:
                        Serial.printf("[WSc] Disconnected!\n");
                        if(disconnectedBuffer-- == 0){
                            this->disconnectedHandler.run();
                        }
                        break;
                    case WStype_CONNECTED: 
                        Serial.printf("[WSc] Connected to url: %s\n", payload);
                        uint8_t macAdrs[WL_MAC_ADDR_LENGTH];
                        WiFi.macAddress(macAdrs);
                        webSocket.sendBIN((uint8_t*)macAdrs, WL_MAC_ADDR_LENGTH);
                        break;
                    case WStype_TEXT:
                        Serial.printf("[WSc] get text: %s\n", payload);
                        // ctrlLumHandler.run(byte(atoi((char *)payload)));
                        break;
                    case WStype_BIN:
                        Serial.printf("[WSc] get binary length: %u\n", length);
                        ctrlLumHandler.run(byte(atoi((char *)payload)));
                        // hexdump(payload, length);
                        // send data to server
                        // webSocket.sendBIN(payload, length);
                        break;
                    case WStype_PING:
                        // pong will be send automatically
                        Serial.printf("[WSc] get ping\n");
                        break;
                    case WStype_PONG:
                        // answer to a ping we send
                        Serial.printf("[WSc] get pong\n");
                        break;
                    case WStype_ERROR:
                        Serial.printf("Error\n");
                        break;
                    default:
                        Serial.printf("default\n");
                        break;
                }
            });
            webSocket.setReconnectInterval(5000);
            webSocket.enableHeartbeat(60000, 3000, 2);
            Serial.printf("Now WS connected to ws://%s:%d\n", TO_LITERAL(DEFAULT__SERVER), DEFAULT__WS__PORT); 
            return 1;
        }

        bool update(){
            webSocket.loop();
            // const int packetSize = Udp.parsePacket();
            // if (packetSize){
            //     const uint8_t * buffer = (const uint8_t *)malloc(packetSize);
            //     Udp.read((char*)buffer, packetSize);
            //     ctrlPacketHandler.run(buffer, packetSize);
            //     delete buffer;
            // }
            return WiFi.isConnected();
        }

         void onControlReceived(Tools::ControlLumHandler lumHandler){
            this->ctrlLumHandler = lumHandler;
        }
        
        void onDisconnected(Tools::DisconnectedHandler disconnectedHandler){
            this->disconnectedHandler = disconnectedHandler;
        }
};


#endif // WSHelper_h