#ifndef NetworkHelper_h
#define NetworkHelper_h

#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <ESP8266WebServer.h>
#include "builtin_files.h"
#include "Tools.h"
#include "ServerHelper.h"

class NetworkHelper{
    WiFiUDP Udp;
    ESP8266WebServer * confServer;
    Tools::ControlPacketHandler ctrlPacketHandler;
    
    public :
        enum Status { NONE, STARTING, OFFLINE, ONLINE };
        Status status = NONE;
        struct ConnectionConf;

        NetworkHelper (ConnectionConf conf = ConnectionConf()) : conf(conf) {}
        virtual ~NetworkHelper(){
            delete confServer;
        }

        void onControlReceived(Tools::ControlPacketHandler packetHandler){
            this->ctrlPacketHandler = packetHandler;
        }
        int begin(Tools::RunHandler<bool> connectionHandler = Tools::DO_NOTHING) {
            status = STARTING;
            
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
                Udp.begin(conf.getInPort());
                Serial.printf("Now listening at IP %s, UDP port %d\n", WiFi.localIP().toString().c_str(), conf.getInPort());
                status = ONLINE;
                
            }else if(WiFi.status() == WL_NO_SSID_AVAIL || WiFi.status() == WL_WRONG_PASSWORD){
                WiFi.disconnect(true, true);
                WiFi.setHostname(conf.getDefaultSSID_PWD().c_str());
                
                if(!WiFi.softAP(conf.getDefaultSSID_PWD(), conf.getDefaultSSID_PWD())){
                    Serial.printf("Unable to create %s", conf.getDefaultSSID_PWD().c_str());
                    ESP.restart();
                }
                
                confServer = new ESP8266WebServer(80);

                confServer->on("/", HTTP_GET, [this](){
                    confServer->send(200, "text/html", FPSTR(confPage));
                });

                confServer->onNotFound([this]() {
                    confServer->send(404, "text/html", FPSTR(notFoundContent));
                });

                Serial.println("Configure ta flamme pour rejoindre l'incendie.");

                confServer->begin();
                status = OFFLINE;
            }else{
                Serial.printf("Unable to connect %s", conf.getSSID().c_str());
                ESP.restart();
            }

            uint8_t macAddress[WL_MAC_ADDR_LENGTH];
            WiFi.macAddress (macAddress);
            return ServerHelper::RegisterRequest()
                        .setData(macAddress)
                        .setKey(conf.getKey())
                        .setUser(conf.getUser())
                        .setPWD(conf.getPass())
                        .send(conf.getServerName())
                        .read()
                        .ifValid()
                        .getValue();
        }



        void update(){
            if(confServer){
                confServer->handleClient();
            }

            // const int packetSize = Udp.parsePacket();
            // if (packetSize){
            //     const uint8_t * buffer = (const uint8_t *)malloc(packetSize);
            //     Udp.read((char*)buffer, packetSize);
            //     ctrlPacketHandler.run(buffer, packetSize);
            //     delete buffer;
            // }
        }
      
        

        bool is(Status state){
            return status == state;
        }


        struct ConnectionConf {
            String key;
            String user;
            String pass;
            String server_name;
            String default_ssid_pwd;
            String ssid;
            String pwd;
            uint16_t inPort;
            uint16_t outPort;
            public :
                ConnectionConf () { setSSID("ConnectionConf").setPWD("").setInPort(8888).setOutPort(9999).setDefaultSSID_PWD("ConnectionConf").setServerName("ConnectionConf"); }
                ConnectionConf (const ConnectionConf &copy  ) {
                    setUser(copy.user);
                    setPass(copy.pass);
                    setKey(copy.key);
                    setSSID(copy.ssid);
                    setPWD(copy.pwd);
                    setInPort(copy.inPort);
                    setOutPort(copy.outPort);
                    setDefaultSSID_PWD(copy.default_ssid_pwd);
                    setServerName(copy.server_name);
                }
                ConnectionConf & setKey(String value) { 
                    key = value;
                    return *this; 
                }
                String getKey(){return key;}

                ConnectionConf & setUser(String value) { 
                    user = value;
                    return *this; 
                }
                String getUser(){return user;}

                ConnectionConf & setPass(String value) { 
                    pass = value;
                    return *this; 
                }
                String getPass(){return pass;}

                ConnectionConf & setDefaultSSID_PWD(String value) { 
                    default_ssid_pwd = value;
                    return *this; 
                }
                String getDefaultSSID_PWD(){return default_ssid_pwd;}

                ConnectionConf & setServerName(String value) { 
                    server_name = value;
                    return *this; 
                }
                String getServerName(){return server_name;}

                ConnectionConf & setSSID(String value) { 
                    ssid = value;
                    return *this; 
                }
                String getSSID(){return ssid;}
                ConnectionConf & setPWD(String value) { 
                    pwd = value;
                    return *this; 
                }
                String getPWD(){return pwd;}
                ConnectionConf & setInPort(uint16_t value) { 
                    inPort = value;
                    return *this; 
                }
                uint16_t getInPort(){return inPort;}
                ConnectionConf & setOutPort(uint16_t value) { 
                    outPort = value;
                    return *this; 
                }
                uint16_t getOutPort(){return outPort;}
                String toString(){
                    return 
                    "SSID    : " + ssid + "\n" +
                    "pwd     : " + pwd + "\n" +
                    "inPort  : " + String(inPort) + "\n" +
                    "outPort : " + String(outPort) + "\n";
                }
        };

    private :
        ConnectionConf conf;

};


#endif // NetworkHelper_h