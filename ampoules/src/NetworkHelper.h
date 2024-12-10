#ifndef NetworkHelper_h
#define NetworkHelper_h

// #include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <ESP8266WebServer.h>
#include "Tools.h"
// #include "ServerHelper.h"

class NetworkHelper{
    public :
        static bool connect(String ssid, String pwd, Tools::RunHandler<bool> connectionHandler = Tools::DO_NOTHING) {
            WiFi.begin(ssid, pwd);
            long t0 = millis();
            Serial.printf("Connecting to %s", ssid.c_str());
            bool value = Tools::idle({
                [connectionHandler, t0]() mutable {
                    if(millis()-t0 > 500){
                        Serial.print(".");
                        t0 = millis();
                    }
                    connectionHandler.run();
                    return WiFi.status() == WL_CONNECTED;
                }
            }, 10000, 10);
            Serial.println(value ? "DONE" : "FAIL");
            return value;
        }
};


#endif // NetworkHelper_h