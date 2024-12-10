#ifndef Tools_h
#define Tools_h

#include <EEPROM.h>
#include <Arduino.h>
#include <ArduinoOTA.h>

// #include <functional>
// #include <utility>

class Tools{

    
    

    public :
        static const uint8_t MAX_STRING_LENGTH = 64;
        struct Settings { 
            char SSID[MAX_STRING_LENGTH] = "";
            char PWD[MAX_STRING_LENGTH] = "";
        };
        typedef std::array<uint8_t, WL_MAC_ADDR_LENGTH> MAC_ADDRESS;
    private :
        union ADDRESS_CONVERTER {
            MAC_ADDRESS macAddress;
            uint8_t bytes[WL_MAC_ADDR_LENGTH];
        };
    public :
        static MAC_ADDRESS getMacAddress(){
            uint8_t macAdrs[WL_MAC_ADDR_LENGTH];
            WiFi.macAddress(macAdrs);
            ADDRESS_CONVERTER addressConverter;
            memcpy (addressConverter.bytes, macAdrs, WL_MAC_ADDR_LENGTH);
            return addressConverter.macAddress;
        }
        static String getFlammeId(){
            MAC_ADDRESS macAddress = Tools::getMacAddress();
            String result = "Flamme-";
            String byte4 = String(macAddress[3], HEX);
            byte4.toUpperCase();
            String byte5 = String(macAddress[4], HEX);
            byte5.toUpperCase();
            String byte6 = String(macAddress[5], HEX);
            byte6.toUpperCase();
            return result + byte4 + byte5 + byte6;
        }

        static bool wait(uint16_t time){
            uint32_t t0 = millis();
            Serial.printf("WAIT %sseconds", String(1 + time/1000).c_str());
            Tools::idle({
                [t0]() mutable {
                    if(millis()-t0 > 500){
                        Serial.print(".");
                        t0 = millis();
                    }
                    return false;
                }
            }, time, 10);
            Serial.println("DONE");
            return true;
        }
    
    class EEPROMHelper{
        public:
            
            EEPROMHelper(){}
            void begin(){
                EEPROM.begin(sizeof(Settings));
            }

            Settings getSetings(){
                Settings settings;
                EEPROM.get(0, settings);
                return settings;
            }

            void setSetings(String SSID, String PWD){
                Settings settings;
                SSID.toCharArray(settings.SSID, SSID.length()+1);
                PWD.toCharArray(settings.PWD, PWD.length()+1);
                EEPROM.put(0, settings); //write data to array in ram 
                EEPROM.commit();
            }
            void end(){
                EEPROM.end();
            }
    };

    template<class T>
    struct RunHandler {
        using RunHandlerFn = std::function<T(void)>;
        RunHandler() {};
        RunHandler(RunHandlerFn dec) : run {std::move(dec)} {};
        RunHandlerFn run;
        T operator()() {
            return this->run();
        };
    };

    struct ControlPacketHandler {
        using ControlPacketHandlerFn = std::function<void(const uint8_t *, const int)>;
        ControlPacketHandler() {};
        ControlPacketHandler(ControlPacketHandlerFn dec) : run {std::move(dec)} {};
        ControlPacketHandlerFn run;
        void operator()(const uint8_t * p,  const int l) {
            this->run(p, l);
        };
    };



    struct ControlLumHandler {
        using ControlLumHandlerFn = std::function<void(const uint8_t)>;
        ControlLumHandler() {};
        ControlLumHandler(ControlLumHandlerFn dec) : run {std::move(dec)} {};
        ControlLumHandlerFn run;
        void operator()(const uint8_t p) {
            this->run(p);
        };
    };



    struct DisconnectedHandler {
        using DisconnectedHandlerFn = std::function<void(void)>;
        DisconnectedHandler() {};
        DisconnectedHandler(DisconnectedHandlerFn dec) : run {std::move(dec)} {};
        DisconnectedHandlerFn run;
        void operator()() {
            this->run();
        };
    };

    
    static Tools::RunHandler<bool> DO_NOTHING;


    static bool idle(Tools::RunHandler<bool> action, uint32_t length = 30000, uint32_t wait = 10 ) {
        bool result = false;
        uint32_t t0 = millis();
        while (millis() - t0 < length) {
            result |= action();
            if(result)break;
            if(wait > 0 ){
                delay(wait);
            }
        }
        return result;
    } 
        
    private : 
        Tools(){}
        virtual ~Tools(){
        }
};


Tools::RunHandler<bool> Tools::DO_NOTHING = {[]()->bool{return true;}};


#endif //Tools_h