#include <ArduinoOTA.h>
#include <EEPROM.h>
#include "NetworkHelper.h"
#include "ServerHelper.h"
#include "BulbController.h"
#include "Simulacre.h"
#include "secret.h"
#include "Tools.h"
#include "WifiConfHelper.h"
#include "UDPHelper.h"
#include "WSHelper.h"

uint16_t myID = 0;
Tools::MAC_ADDRESS macAddress = Tools::getMacAddress();
BaseLeaf * leaf;

void setup() {
  BulbController::OFF();
  Serial.begin(115200);
  while(!Serial){delay(1);}

  Serial.println("");
  Serial.println("");
  Serial.println("");

  
  uint16_t offsetStart = (macAddress[5] + macAddress[4] * 256) * 3;

 // WAIT somes milliseconds to avoid router connection bottleneck (min 0sec, max ~&80sec)
  Serial.printf("WAIT %sseconds", String(1 + offsetStart/1000).c_str());
  uint32_t t0 = millis();
  Tools::idle({
    [t0, offsetStart]() mutable {
      Serial.print(".");
      uint8_t l = uint8_t(((millis() - t0) / (float)offsetStart) * 255);
      BulbController::setLum(l);
      return false;
    }
  }, offsetStart, 100);
  Serial.println("DONE");

  // CONNECT TO incendie WIFI
  t0 = millis();
  bool isConnected = NetworkHelper::connect(TO_LITERAL(DEFAULT__SSID), TO_LITERAL(DEFAULT__PWD), {
    [t0](){
      float t = sin(fmod((millis() - t0)/ 3000.0f, 1.0f) * TWO_PI - PI/2 ) * 0.5 + 0.5;
      BulbController::setLum(int(t*255));
      return true;
    }
  });
  BulbController::OFF();

  ArduinoOTA.setHostname(Tools::getFlammeId().c_str());
  ArduinoOTA.begin();
    
  if(isConnected){
    ServerHelper * api = new ServerHelper();
    int result = api->begin();
    delete api;
    if(result == -1){           // MODE SIMULACRE
      leaf = new Simulacre();
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
    t0 = millis();
    bool isConnectedStoredWifi = NetworkHelper::connect(settings.SSID, settings.PWD, {
      [t0](){
        float t = sin(fmod((millis() - t0)/ 3000.0f, 1.0f) * TWO_PI - PI/2 ) * 0.5 + 0.5;
        BulbController::setLum(int(t*255));
        return true;
      }
    });

    if(isConnectedStoredWifi){  // MODE ONLINE
      ESP.restart();
      WSHelper * ws = new WSHelper();
      ws->begin();
      ws->onControlReceived({
        [](const uint8_t value){
          Serial.println(value);
          BulbController::setLum(value);
        }
      });
      ws->onDisconnected({
        [&](){
          leaf = new Simulacre();
        }
      });
      leaf = ws;
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