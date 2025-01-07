#ifndef ServerHelper_h
#define ServerHelper_h

// #include <Arduino.h>
#include <ESP8266WiFi.h>
#include "Tools.h"
#include "secret.h"
#include "BaseLeaf.h"

class ServerHelper : public BaseLeaf{
    public :

        ServerHelper()
        : BaseLeaf(){
            
        }

        int begin(){
            Serial.print("Connection to API server");
            const String host = TO_LITERAL(DEFAULT__SERVER);
            int port = DEFAULT__SERVER__PORT;
            WiFiClient client;
            bool success = Tools::idle({
                [&client, host, port]() {
                    Serial.print(".");
                    return client.connect(host, port);
                }
            }, 30000, 1000);
            if (!success) {
                return -1;
            }

            Tools::MAC_ADDRESS macAddress = Tools::getMacAddress();
            String hostname = Tools::getFlammeId().c_str();
            String payload = "{\"Hostname\":\""+hostname+".local\", \"MacAddress\":["+String(macAddress[0])+", "+String(macAddress[1])+", "+String(macAddress[2])+", "+String(macAddress[3])+", "+String(macAddress[4])+", "+String(macAddress[5])+"]}";
            Serial.println(payload);
            String req = "POST /flamme HTTP/1.1\r\n"
                        "Host: " + host + "\r\n"
                        "Content-Type: application/json\r\n"
                        "Content-Length: " + payload.length() + "\r\n"
                        "Connection: close\r\n\r\n"+
                        payload;
            // Send the POST request
            client.print(req);
            Serial.print("Wait");
            bool isValid = Tools::idle({
                [&client]() {
                    Serial.print(".");
                    return client.available();
                }
            }, 30000, 2);

            if(!isValid)return -1;
            String response;
            Serial.print("Reading");
            bool result = Tools::idle({
                [&client, &response]() {
                    Serial.print(".");
                    response += client.readStringUntil('\r');
                    return ! (client.status() == tcp_state::ESTABLISHED || client.available());
                }
            }, 30000, 10);
            Serial.println("Done");

            if(!result){
                Serial.println("Reading troubble");
                return -1;
            }
            Serial.println("Response:");
            Serial.println(response);
            if(response.indexOf("HTTP/1.1 200")<0){
                Serial.println("response is not 200");
                return -1;
            }
            String data = response.substring(response.indexOf("flamme id : "));
            data = data.substring(12, response.indexOf("\r\n"));
            Serial.printf("-%s-", data.c_str() );
            Serial.println("");
            client.stop();
            return data.toInt();
    }

     virtual bool update() override {
        return true;
    }

    virtual ~ServerHelper(){}
};

#endif // ServerHelper_h