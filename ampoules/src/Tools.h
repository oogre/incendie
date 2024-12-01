#ifndef Tools_h
#define Tools_h

#include <EEPROM.h>
#include <Arduino.h>
// #include <functional>
// #include <utility>

class Tools{

    public :
    
    class EEPROMHelper{
        const uint16_t LEN = 512;
        const uint8_t STRING_MAX_LEN = 100;
        
        public:
            EEPROMHelper(){}
            void begin(){
                EEPROM.begin(LEN);
            }

            void setId(uint16_t id){
                uint8_t upperbyte=(uint8_t) id/256;
                uint8_t lowerbyte=(uint8_t) id&255;
                EEPROM.put(0, upperbyte);
                EEPROM.put(1, lowerbyte);
            }
            uint16_t getId(){
                uint16_t offset = 0;
                uint8_t upperbyte;
                uint8_t lowerbyte;
                EEPROM.get(offset + 0, upperbyte);
                EEPROM.get(offset + 1, lowerbyte);
                return (uint16_t) (lowerbyte+256*upperbyte);
            }

            void setSSID(String ssid){
                setString(ssid, 2);
            }
            String getSSID(){
                return getString(2);
            }

            void setPWD(String pwd){ 
                setString(pwd, 2+STRING_MAX_LEN);
            }
            String getPWD(){ 
                return getString(2+STRING_MAX_LEN);
            }

            void setString(String value, uint16_t offset){
                uint8_t charLength =  (uint8_t) value.length();
                for (uint8_t i = 0; i < charLength && i < STRING_MAX_LEN; ++i){
                    EEPROM.write(offset + i, value[i]); 
                }
                EEPROM.write(offset + charLength, '\n');
            }

            String getString(uint16_t offset){
                String value = "";
                uint8_t charLength = STRING_MAX_LEN;
                for (int i = 0; i < charLength; ++i){
                    char tmp = char(EEPROM.read(offset + i));
                    if(tmp == '\n') return value;
                    value += tmp;
                }
                return "";
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