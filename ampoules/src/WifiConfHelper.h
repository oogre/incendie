#ifndef WifiConfHelper_h
#define WifiConfHelper_h

// #include <Arduino.h>
#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include "builtin_files.h"
#include "Tools.h"
#include "BaseLeaf.h"



class WifiConfHelper : public BaseLeaf{
    ESP8266WebServer * confServer;
    public :
        WifiConfHelper() 
        : BaseLeaf(){
            String ssid = Tools::getFlammeId();
            WiFi.disconnect(true, true);
            
            Serial.printf("Creation of Access Point (%s)", ssid.c_str());
            Serial.println("");

            if(!WiFi.softAP(ssid)){
                Serial.printf("Unable to create %s", ssid.c_str());
                ESP.restart();
            }

            WiFi.setHostname(ssid.c_str());
            
            confServer = new ESP8266WebServer(80);

            confServer->on("/", HTTP_GET, [this](){
                confServer->send(200, "text/html", FPSTR(confPage));
            });

            confServer->on("/setNetwork", HTTP_POST, [this](){
                confServer->send(200, "text/html", FPSTR(confPage));
                String data = confServer->arg("plain");
                String SSID = data.substring(0, data.indexOf(", "));
                String PWD = data.substring(data.indexOf(", ")+2);
                Tools::EEPROMHelper memory;
                memory.begin();
                memory.setSetings(SSID, PWD);
                memory.end();
                ESP.restart();
            });
            
            confServer->onNotFound([this]() {
                confServer->send(404, "text/html", FPSTR(notFoundContent));
            });

            Serial.printf("Connect to %s Wifi and on your browser : http://%s ", ssid.c_str(), "192.168.4.1");
            Serial.println("");

            confServer->begin();
        }

        virtual bool update() override {
            confServer->handleClient();
            return true;
        }

        virtual ~WifiConfHelper(){
            delete confServer;
        }
};


#endif // WifiConfHelper_h