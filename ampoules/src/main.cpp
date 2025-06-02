#include <Arduino.h>

#include "NetworkHelper.h"
#include "BulbController.h"
#include "Simulacre.h"
#include "secret.h"
#include "Tools.h"
#include "WifiConfHelper.h"
#include "WSHelper.h"

namespace INCENDIE {
  enum STATUS {
      NONE,
      STARTING, 
      WAITING, 
      CONNECTING_PERFORMANCE,
      CONNECTING_HOME,
      PERFORMANCE,
      HOME,
      CONFIGURATION_HOME,
      SIMULACRE
  };
}

enum INCENDIE::STATUS state = INCENDIE::NONE;

Tools::MAC_ADDRESS macAddress = Tools::getMacAddress();

BaseLeaf * leaf;
BaseLeaf * simulation;
uint32_t t0;

void setup(){
  BulbController::init();
  delay(1000);
  Serial.begin(115200);
  while(!Serial){delay(1);}
  
  state = INCENDIE::STARTING;

  Tools::EEPROMHelper memory;
  memory.begin();
  Tools::Settings settings = memory.getSetings();
  memory.end();
  
  // CONNECT TO STORED WIFI
  uint32_t t1 = millis();
  bool isConnectedStoredWifi = NetworkHelper::connect(settings.SSID, settings.PWD, {
    [t1](){
      state = INCENDIE::CONNECTING_HOME;
      float t = sin(fmod((millis() - t1)/ 10000.0f, 1.0f) * TWO_PI - PI/2 ) * 0.5 + 0.5;
      BulbController::setLum(int(t*255));
      BulbController::blueTOGGLE();
      delay(10);
      return true;
    }
  });
  BulbController::OFF();
  BulbController::blueOFF();

  if(isConnectedStoredWifi){  // MODE HOME
    state = INCENDIE::HOME;
    WSHelper * ws = new WSHelper();
    ws->begin();
    ws->onControlReceived({
      [](const uint8_t value){
        // Serial.println(value);
        BulbController::setLum(value);
      }
    });
    // ws->onDisconnected({
    //   [&](){
    //     leaf = new Simulacre();
    //     state = INCENDIE::SIMULACRE;
    //   }
    // });
    leaf = ws;
  }else{                      // MODE CONFIGURATION
    state = INCENDIE::CONFIGURATION_HOME;
    t0 = millis();
    leaf = new WifiConfHelper();
    simulation = new Simulacre();
  }

}

void loop(){
  if(leaf != nullptr){
    leaf->update();      
  }
  
  if(state == INCENDIE::CONFIGURATION_HOME){
    simulation->update();
  }
}

/*






void setup() {
  state = INCENDIE::STARTING;
  BulbController::BLINK(20, 50, 50);
  //Serial.begin(115200);
  //while(!Serial){delay(1);}
  
  delay(3000);
  // Serial.println("INIT");
  // Serial.println("");
  // Serial.println("");

  ArduinoOTA.setHostname(Tools::getFlammeId().c_str());
  ArduinoOTA.begin();

  // Serial.println("YO");
  Tools::EEPROMHelper memory;
  memory.begin();
  Tools::Settings settings = memory.getSetings();
  memory.end();
  // Serial.println("LO");
  // CONNECT TO STORED WIFI
  uint32_t t1 = millis();
  bool isConnectedStoredWifi = NetworkHelper::connect(settings.SSID, settings.PWD, {
    [t1](){
      state = INCENDIE::CONNECTING_HOME;
      float t = sin(fmod((millis() - t1)/ 3000.0f, 1.0f) * TWO_PI - PI/2 ) * 0.5 + 0.5;
      BulbController::setLum(int(t*255));
      return true;
    }
  });
  // Serial.println(isConnectedStoredWifi);
  if(isConnectedStoredWifi){  // MODE HOME
    state = INCENDIE::HOME;
    WSHelper * ws = new WSHelper();
    ws->begin();
    ws->onControlReceived({
      [](const uint8_t value){
        // Serial.println(value);
        BulbController::setLum(value);
      }
    });
    // ws->onDisconnected({
    //   [&](){
    //     leaf = new Simulacre();
    //     state = INCENDIE::SIMULACRE;
    //   }
    // });
    leaf = ws;
  }else{                      // MODE CONFIGURATION
    state = INCENDIE::CONFIGURATION_HOME;
    t0 = millis();
    leaf = new WifiConfHelper();
  }
}

void loop(){
  ArduinoOTA.handle();
  if(leaf != nullptr){
    leaf->update();      
  }

  switch(state){
    case INCENDIE::CONFIGURATION_HOME : 
      float t = sin(fmod((millis() - t0) / 1000.0f, 1.0f) * TWO_PI - PI/2 ) * 0.5 + 0.5;
      BulbController::setLum(int(t*255));
    break;
  }
}

*/