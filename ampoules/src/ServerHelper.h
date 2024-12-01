#ifndef ServerHelper_h
#define ServerHelper_h

// #include <Arduino.h>
#include <ESP8266WiFi.h>
#include <nlohmann/json.hpp>
#include "Tools.h"

class ServerHelper{

    public :
        struct BaseRequest {
            WiFiClient client;
            bool isValid = false;
            nlohmann::json dataResp;
            String bodyResponse;
            String user;
            String pwd;
            String query;
            public : 
                BaseRequest () { setUser("user").setPWD("pwd").setQuery("").setKey(""); }
                BaseRequest (const BaseRequest &copy  ) {
                    setUser(copy.user);
                    setPWD(copy.pwd);
                    setQuery(copy.query);
                }
                
                BaseRequest & setKey(String value) { 
                    // xxtea.setKey(value);
                    return *this; 
                }

                BaseRequest & setUser(String value) { 
                    user = value;
                    return *this; 
                }
                String getUser(){return user;}

                BaseRequest & setPWD(String value) { 
                    pwd = value;
                    return *this; 
                }
                String getPWD(){return pwd;}

                BaseRequest & setQuery(String value) { 
                    query = value;
                    return *this; 
                }
                String getQuery(){return query;}

                virtual nlohmann::json toJSON(){
                    nlohmann::json json;
                    json["USER"] = user.c_str();
                    json["PWD"] = pwd.c_str();
                    return json;
                }

                virtual BaseRequest & send(const String serverName, uint16_t serverPort){
                    
                    
                    Serial.print("Connection");
                    bool success = Tools::idle({
                        [this, serverName, serverPort]() {
                            Serial.print(".");
                            return client.connect(serverName, serverPort);
                        }
                    }, 30000, 1000);
                    Serial.println("Done");
                    
                    // Connect to the server
                    if (!success) {
                        Serial.println("Connection to server failed");
                        isValid = false;
                        return *this;
                    }

                    String payload = toJSON().dump().c_str();
                    // payload = xxtea.encrypt(payload);

                    // unsigned char base64[128]; // 20 bytes for output + 1 for null terminator

                    // // encode_base64() places a null terminator automatically, because the output is a string
                    // unsigned int base64_length = encode_base64((unsigned char*)payload.c_str(), strlen((char *) payload.c_str()), base64);


                    String req = "POST " + getQuery() + " HTTP/1.1\r\n" +
                                 "Host: " + serverName + "\r\n" +
                                 "Content-Type: application/json\r\n" +
                                 "Content-Length: " + payload.length() + "\r\n" +
                                 "Connection: close\r\n\r\n" +
                                 payload;


                    // Send the POST request
                    client.print(req);
                    Serial.println("Send:");
                    Serial.println(req);

                    Serial.print("Wait");
                    Tools::idle({
                        [this]() {
                            Serial.print(".");
                            return client.available();
                        }
                    }, 10000, 10);
                    Serial.println("Done");
                    isValid = true;
                    return *this;
                }
                virtual BaseRequest & read(){
                    if(!isValid)return *this; 
                    String response;
                    Serial.print("Reading");
                    bool result = Tools::idle({
                        [this, &response]() {
                            Serial.print(".");
                            response += client.readStringUntil('\r');
                            return ! (client.status() == tcp_state::ESTABLISHED || client.available());
                        }
                    }, 30000, 10);
                    Serial.println("Done");

                    if(!result){
                        Serial.println("Reading troubble");
                        isValid = false;
                        return *this;
                    }

                    Serial.println("Response:");
                    Serial.println(response);

                    if(response.indexOf("HTTP/1.1 200")<0){
                        Serial.println("response is not 200");
                        isValid = false;
                        return *this;
                    }

                    if(response.indexOf("\n\n")<0){
                        Serial.println("body len not found");
                        isValid = false;
                        return *this;
                    }
                    int bodyStart = response.indexOf("\n\n") + 2;
                    response = response.substring(bodyStart);

                    if(response.indexOf("\n")<0){
                        Serial.println("body not found");
                        isValid = false;
                        return *this;
                    }
                    bodyStart = response.indexOf("\n") + 1;
                    response = response.substring(bodyStart);

                    if(response.indexOf("\n")<0){
                        Serial.println("body reading error");
                        isValid = false;
                        return *this;
                    }

                    int bodyStop = response.indexOf("\n");
                    response = response.substring(0, bodyStop);
                    
                    bodyResponse = response;
                    
                    client.stop();
                    isValid = true;
                    return *this; 
                }

                virtual BaseRequest & ifValid(){
                    if(!isValid){
                        Serial.println("ifValid :'(");
                        return *this; 
                    }
                    dataResp = nlohmann::json::parse(bodyResponse);
                    if(!dataResp.contains("success") || !dataResp["success"].get<bool>()){
                        Serial.println("NOT a success");
                        isValid = false;
                        return *this; 
                    }
                    dataResp = dataResp["data"];
                    return *this; 
                }
                virtual int getValue (){
                    Serial.println("getValue :'(");
                    return -1;
                }
            private:
        };

        struct RegisterRequest : BaseRequest {
            public : 
                typedef std::array<uint8_t, WL_MAC_ADDR_LENGTH> MAC_ADDRESS;
                
                union ADDRESS_CONVERTER {
                    MAC_ADDRESS macAddress;
                    uint8_t bytes[WL_MAC_ADDR_LENGTH];
                };
                MAC_ADDRESS data;
                RegisterRequest () 
                : BaseRequest() { 
                    setQuery("/register");
                }
                RegisterRequest (const RegisterRequest &copy  ) 
                : BaseRequest(copy) {
                    setData(copy.data);
                }

                RegisterRequest & setData(uint8_t * macAddress) { 
                    ADDRESS_CONVERTER addressConverter;
                    memcpy (addressConverter.bytes, macAddress, WL_MAC_ADDR_LENGTH);
                    return setData(addressConverter.macAddress);
                }

                RegisterRequest & setData(MAC_ADDRESS value) { 
                    data = value;
                    return *this; 
                }
                MAC_ADDRESS getData(){return data;}

                virtual nlohmann::json toJSON() override {
                    nlohmann::json json = BaseRequest::toJSON();
                    json["data"] = toArray(data);
                    return json;
                }

                int getValue () override {
                    if(!isValid)return BaseRequest::getValue(); 
                    return dataResp["id"].get<int>();
                }
            private : 
                nlohmann::json toArray(MAC_ADDRESS address){
                    return nlohmann::json::array({address[0], address[1], address[2], address[3], address[4], address[5]});
                }
                String toString(MAC_ADDRESS address){
                    String result = "";
                    result += String(address[0], HEX) + ":" + String(address[1], HEX) + ":" + String(address[2], HEX) + ":" + String(address[3], HEX) + ":" + String(address[4], HEX) + ":" + String(address[5], HEX);
                    return result;
                }
        };
        
    private :
        ServerHelper(){}
        virtual ~ServerHelper(){}
};

#endif // ServerHelper_h