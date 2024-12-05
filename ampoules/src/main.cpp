#include <ArduinoOTA.h>
#include <EEPROM.h>
#include "NetworkHelper.h"
#include "ServerHelper.h"
#include "BulbController.h"
#include "secret.h"
#include "Tools.h"
#include "WifiConfHelper.h"
#include "UDPHelper.h"

uint16_t myID = 0;
Tools::MAC_ADDRESS macAddress = Tools::getMacAddress();
BaseLeaf * leaf;

void setup() {
  Serial.begin(115200);
  while(!Serial){delay(1);}

  Serial.println("");
  Serial.println("");
  Serial.println("");

  
  uint16_t offsetStart = (macAddress[5] + macAddress[4] * 256) / 2;

 // WAIT somes milliseconds to avoid router connection bottleneck (min 0sec, max ~60sec)
  Serial.printf("WAIT %sseconds", String(1 + offsetStart/1000).c_str());
  bool on = false;
  Tools::idle({
    [on]() mutable {
      Serial.print(".");
      on = !on;
      if(on){
        BulbController::ON();
      } else {
        BulbController::OFF();
      } 
      return false;
    }
  }, offsetStart, 500);
  Serial.println("DONE");

  // CONNECT TO incendie WIFI
  bool isConnected = NetworkHelper::connect(TO_LITERAL(DEFAULT__SSID), TO_LITERAL(DEFAULT__PWD), {
    [](){
      BulbController::animSine(fmod(millis() / 3000.0f, 1.0f) );
      return true;
    }
  });
  BulbController::OFF();

  if(isConnected){
    ArduinoOTA.setHostname(Tools::getFlammeId().c_str());
    ArduinoOTA.begin();
    ServerHelper * api = new ServerHelper();
    int result = api->begin();
    delete api;
    if(result == -1){           // MODE SIMULACRE
      Serial.println("KO");
      BulbController::BLINK(2, 50, 50);
      BulbController::ON();
    }else{                      // MODE PERFORMANCE
      myID = result;
      UDPHelper * udp = new UDPHelper();
      udp->begin();
      leaf = udp;
      udp->onControlReceived({
        [](const uint8_t * packet, const int lenght){
          uint8_t value = *(packet+myID);
          Serial.println(value);
          BulbController::setLum(value);
        }
      });

      BulbController::BLINK(2, 50, 50);
      BulbController::OFF();
    }
  }else{
    Tools::EEPROMHelper memory;
    memory.begin();
    Tools::Settings settings = memory.getSetings();
    memory.end();
    // CONNECT TO STORED WIFI
    bool isConnectedStoredWifi = NetworkHelper::connect(settings.SSID, settings.PWD, {
      [](){
        BulbController::animSine(fmod(millis() / 3000.0f, 1.0f) );
        return true;
      }
    });

    if(isConnectedStoredWifi){  // MODE ONLINE
      Serial.println("OK");
      BulbController::BLINK(2, 250, 250);
      BulbController::OFF();
    }else{                      // MODE CONFIGURATION
      leaf = new WifiConfHelper();
      BulbController::BLINK(2, 250, 250);
      BulbController::ON();
    }
  }
}

void loop(){
  ArduinoOTA.handle();
  if(leaf != nullptr){
    leaf->update();
  }
}