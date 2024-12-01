#include <ArduinoOTA.h>
#include <EEPROM.h>
#include "NetworkHelper.h"
#include "BulbController.h"
#include "secret.h"

NetworkHelper network;


uint16_t myID = 0;

void setup() {

  Serial.begin(115200);
  while(!Serial){delay(1);}

  BulbController::OFF();
  
  NetworkHelper::Conf conf = NetworkHelper::Conf()
                              .setSSID(TO_LITERAL(DEFAULT__SSID)) // at live show
                              .setPWD(TO_LITERAL(DEFAULT__PWD)) // at live show
                              .setUser(TO_LITERAL(DEFAULT__USER))
                              .setPass(TO_LITERAL(DEFAULT__PASS))
                              .setKey(TO_LITERAL(DEFAULT__KEY))
                              .setServerName(TO_LITERAL(DEFAULT__SERVER))
                              .setServerPort(DEFAULT__SERVER__PORT)
                              .setInPort(DEFAULT__UDP_IN__PORT);
  network = NetworkHelper(conf);

  network.onControlReceived({
    [](const uint8_t * packet, const int lenght){
      BulbController::setLum(*(packet+myID));
    }
  });

  NetworkHelper::Status status = network.begin({
    [](){
      ArduinoOTA.setHostname(network.conf.getFlammeId().c_str());
      ArduinoOTA.begin();
      BulbController::animSine(fmod(millis() / 3000.0f, 1.0f) );
      return true;
    }
  });

  if(status == NetworkHelper::Status::EXHIBITION){
    status = network.runExhibition();
    // myID = (uint32_t)id;
  }  
  
  if(status == NetworkHelper::Status::ONLINE){
    status = network.runOnline();
    // myID = (uint32_t)id;
  }

  if(status == NetworkHelper::Status::NO_NETWORK){
    status = network.runNoNetwork();
  }
  
  if(status == NetworkHelper::Status::NONE){
    ESP.restart();
    return;
  }

  BulbController::OFF();
  BulbController::BLINK(4, 100, 100);
  BulbController::OFF();
}

void loop() {
  ArduinoOTA.handle();
  // if(!network.update()){
  //   return BulbController::FLAME(millis() * 0.1);
  // }
  BulbController::ON();
}
