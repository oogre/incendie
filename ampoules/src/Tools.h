#ifndef Tools_h
#define Tools_h

#include <Arduino.h>
#include <functional>
#include <utility>

class Tools{

    public :
       

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