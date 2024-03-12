#include <Arduino.h>
#include <ESP8266WiFi.h>
#include <WiFiUdp.h>
#include <Preferences.h>
#include "NetworkHelper.h"
#include "BulbController.h"
#include "secret.h"

Preferences prefs;
NetworkHelper network;

const String PROJECT_ID = "incendie";
uint16_t myID = 2;

void setup() {
  Serial.begin(115200);
  BulbController::OFF();
  
  prefs.begin(PROJECT_ID.c_str(), false);

  prefs.clear();

  NetworkHelper::ConnectionConf conf = NetworkHelper::ConnectionConf()
                                        .setDefaultSSID_PWD(PROJECT_ID)
                                        .setUser(prefs.getString("user", TO_LITERAL(DEFAULT__USER)))
                                        .setPass(prefs.getString("pass", TO_LITERAL(DEFAULT__PASS)))
                                        .setKey(prefs.getString("key", TO_LITERAL(DEFAULT__KEY)))
                                        .setServerName(prefs.getString("SERVER_NAME", TO_LITERAL(DEFAULT__SERVER)))
                                        .setSSID(prefs.getString("SSID", TO_LITERAL(DEFAULT__SSID)))
                                        .setPWD(prefs.getString("PWD", TO_LITERAL(DEFAULT__PWD)))
                                        .setInPort(prefs.getUInt("inPort", 8888))
                                        .setOutPort(prefs.getUInt("outPort", 9999));

  network = NetworkHelper(conf);

  network.onControlReceived({
    [](const uint8_t * packet, const int lenght){
      BulbController::setLum(*(packet+myID));
    }
  });

  int id = network.begin({
    [](){
      BulbController::animSine( fmod(millis() / 3000.0f, 1.0f) );
      return true;
    }
  });

  if(id != -1){
    myID = (uint32_t)id;
    Serial.println("MyId : "+String(myID));
  }

  if(network.is(NetworkHelper::Status::ONLINE)){

  }

  BulbController::OFF();
  BulbController::BLINK(4, 100, 100);
  BulbController::OFF();
}

void loop() {
  network.update();
  if(network.is(NetworkHelper::Status::OFFLINE)){
    return BulbController::FLAME(millis() * 0.1);
  }
}
