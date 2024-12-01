#ifndef NetworkHelper_h
#define NetworkHelper_h

// #include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <ESP8266WebServer.h>
#include "builtin_files.h"
#include "Tools.h"
#include <ESP8266Ping.h>
// #include "ServerHelper.h"

class NetworkHelper{
    WiFiUDP Udp;
    ESP8266WebServer * confServer;
    Tools::ControlPacketHandler ctrlPacketHandler;
    
    typedef std::array<uint8_t, WL_MAC_ADDR_LENGTH> MAC_ADDRESS;
    
                
    union ADDRESS_CONVERTER {
        MAC_ADDRESS macAddress;
        uint8_t bytes[WL_MAC_ADDR_LENGTH];
    };
    
    public :
        enum Status { NONE, EXHIBITION, ONLINE, NO_NETWORK };
        struct Conf {
            String key;
            String user;
            String pass;
            String server_name;
            MAC_ADDRESS macAddress;
            uint16_t server_port;
            String config_ssid;
            String ssid;
            String pwd;
            uint16_t inPort;
            public :
                Conf () { 
                    setSSID("")
                    .setPWD("")
                    .setInPort(0)
                    .setConfigSSID("")
                    .setServerName("")
                    .setServerPort(0);
                    uint8_t macAddress[WL_MAC_ADDR_LENGTH];
                    setMacAddress(WiFi.macAddress(macAddress));
                }
                Conf (const Conf &copy  ) {
                    setUser(copy.user);
                    setPass(copy.pass);
                    setKey(copy.key);
                    setSSID(copy.ssid);
                    setPWD(copy.pwd);
                    setInPort(copy.inPort);
                    setConfigSSID(copy.config_ssid);
                    setServerName(copy.server_name);
                    setServerPort(copy.server_port);
                    setMacAddress(copy.macAddress);
                }

                Conf & setKey(String value) { 
                    key = value;
                    return *this; 
                }
                String getKey(){return key;}

                Conf & setUser(String value) { 
                    user = value;
                    return *this; 
                }
                String getUser(){return user;}

                Conf & setPass(String value) { 
                    pass = value;
                    return *this; 
                }
                String getPass(){return pass;}

                Conf & setConfigSSID(String value) { 
                    config_ssid = value;
                    return *this; 
                }
                String getConfigSSID(){return config_ssid;}

                Conf & setServerName(String value) { 
                    server_name = value;
                    return *this; 
                }
                String getServerName(){return server_name;}
                
                Conf & setServerPort(uint16_t value) { 
                    server_port = value;
                    return *this; 
                }
                uint16_t getServerPort(){return server_port;}

                Conf & setSSID(String value) { 
                    ssid = value;
                    return *this; 
                }
                String getSSID(){return ssid;}

                Conf & setPWD(String value) { 
                    pwd = value;
                    return *this; 
                }
                String getPWD(){return pwd;}

                Conf & setInPort(uint16_t value) { 
                    inPort = value;
                    return *this; 
                }
                uint16_t getInPort(){return inPort;}

                Conf & setMacAddress(uint8_t * macAddress) { 
                    ADDRESS_CONVERTER addressConverter;
                    memcpy (addressConverter.bytes, macAddress, WL_MAC_ADDR_LENGTH);
                    return setMacAddress(addressConverter.macAddress);
                }

                Conf & setMacAddress(MAC_ADDRESS value) { 
                    macAddress = value;
                    return *this; 
                }
                MAC_ADDRESS getMacAddress(){return macAddress;}

                String getFlammeId(){
                    String result = "Flamme-";
                    String byte4 = String(macAddress[3], HEX);
                    byte4.toUpperCase();
                    String byte5 = String(macAddress[4], HEX);
                    byte5.toUpperCase();
                    String byte6 = String(macAddress[5], HEX);
                    byte6.toUpperCase();
                    return result + byte4 + byte5 + byte6;
                }

                String toString(){
                    return 
                    "SSID    : " + ssid + "\n" +
                    "pwd     : " + pwd + "\n" +
                    "inPort  : " + String(inPort) + "\n";
                }
        };


        Conf conf;    
        
        NetworkHelper (Conf conf = Conf()) : conf(conf) {}
        virtual ~NetworkHelper(){
            delete confServer;
        }

        void onControlReceived(Tools::ControlPacketHandler packetHandler){
            this->ctrlPacketHandler = packetHandler;
        }

        Status begin(Tools::RunHandler<bool> connectionHandler = Tools::DO_NOTHING) {
            WiFi.begin(conf.getSSID(), conf.getPWD());
            long t0 = millis();
            Serial.printf("Connecting to %s ", conf.getSSID().c_str());
            bool isConnected = Tools::idle({
                [connectionHandler, t0]() mutable {
                    if(millis()-t0 > 500){
                        Serial.print(".");
                        t0 = millis();
                    }
                    connectionHandler.run();
                    return WiFi.status() == WL_CONNECTED;
                }
            }, 10000, 10);
            Serial.println("DONE");

            if(isConnected){
                IPAddress ip (8, 8, 8, 8); // The remote ip to ping
                if(!Ping.ping(ip)){
                    return Status::ONLINE;
                }
                return Status::EXHIBITION;
            }
            
            if(WiFi.status() == WL_NO_SSID_AVAIL || WiFi.status() == WL_WRONG_PASSWORD){
                return Status::NO_NETWORK;
            }

            Serial.printf("Unable to connect %s", conf.getSSID().c_str());
            
            return Status::NONE;

            // return ServerHelper::RegisterRequest()
            //             .setData(macAddress)
            //             .setKey(conf.getKey())
            //             .setUser(conf.getUser())
            //             .setPWD(conf.getPass())
            //             .send(conf.getServerName(), conf.getServerPort())
            //             .read()
            //             .ifValid()
            //             .getValue();
        }

        Status runNoNetwork(){
            WiFi.disconnect(true, true);
            WiFi.setHostname(conf.getFlammeId().c_str());
            
            if(!WiFi.softAP(conf.getFlammeId())){
                Serial.printf("Unable to create %s", conf.getFlammeId().c_str());
                return Status::NONE;
            }
            
            confServer = new ESP8266WebServer(80);

            confServer->on("/", HTTP_GET, [this](){
                confServer->send(200, "text/html", FPSTR(confPage));
            });

            confServer->on("/setNetwork", HTTP_GET, [this](){
                Serial.println(confServer->hostHeader());
                confServer->send(200, "text/html", FPSTR(confPage));
                // RECORD SSID AND PWD
            });
            
            confServer->onNotFound([this]() {
                confServer->send(404, "text/html", FPSTR(notFoundContent));
            });

            Serial.println("Configure ta flamme pour rejoindre l'incendie.");

            confServer->begin();
            return Status::NO_NETWORK;
        }


        Status runExhibition(){
            Udp.begin(conf.getInPort());
            Serial.printf("Now listening at IP %s, UDP port %d\n", WiFi.localIP().toString().c_str(), conf.getInPort()); 
            return Status::EXHIBITION;
        }

        Status runOnline(){
            return Status::ONLINE;
            return Status::NONE;
        }

        bool update(){
            if(confServer){
                confServer->handleClient();
            }
            
            const int packetSize = Udp.parsePacket();
            if (packetSize){
                const uint8_t * buffer = (const uint8_t *)malloc(packetSize);
                Udp.read((char*)buffer, packetSize);
                ctrlPacketHandler.run(buffer, packetSize);
                delete buffer;
            }
            return WiFi.isConnected();
        }
};


#endif // NetworkHelper_h