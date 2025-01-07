#ifndef UDPHelper_h
#define UDPHelper_h

// #include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include "Tools.h"
#include "secret.h"
#include "BaseLeaf.h"

class UDPHelper : public BaseLeaf{
    WiFiUDP Udp;
    Tools::ControlPacketHandler ctrlPacketHandler;
    public :
        UDPHelper()
        : BaseLeaf(){}

        virtual ~UDPHelper(){
        }

        int begin(){
            Udp.begin(DEFAULT__UDP_IN__PORT);
            Serial.printf("Now listening at IP %s, UDP port %d\n", WiFi.localIP().toString().c_str(), DEFAULT__UDP_IN__PORT); 
            return 1;
        }

        bool update(){
            const int packetSize = Udp.parsePacket();
            if (packetSize){
                const uint8_t * buffer = (const uint8_t *)malloc(packetSize);
                Udp.read((char*)buffer, packetSize);
                ctrlPacketHandler.run(buffer, packetSize);
                delete buffer;
            }
            return WiFi.isConnected();
        }

         void onControlReceived(Tools::ControlPacketHandler packetHandler){
            this->ctrlPacketHandler = packetHandler;
        }
};


#endif // UDPHelper_h