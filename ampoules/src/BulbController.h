#ifndef BulbController_h
#define BulbController_h

#include <Arduino.h>
// #include <FastLED.h>

class Math {
    public :
    static float lerp(float a, float b, float t){
        return a + t * (b - a);
    }


    static float nozWave(float phase){
        float root = sin(phase) * 0.5 + 0.5;
        return fmin(1.0, fmax(0.0, fmod(root * 999.9f, 1.0f)));
    }

    private : 
        Math(){}
        virtual ~Math(){}
};

class BulbController{

    public :
        static void setLum(uint8_t value){
            pinMode(0, OUTPUT);
            analogWrite(0, value);
        }

       

        static void ON(){
            setLum(255);
        }

        static void OFF(){
            setLum(0);
        }

        static void BLINK(uint16_t count, uint8_t onDuration, uint8_t offDuration){
            while(count-- > 0){
                BulbController::ON();
                delay(onDuration);
                BulbController::OFF();
                delay(offDuration);
            }
        }

        static void FLAME(float time){
            setLum(255);
        }

    private : 
        BulbController(){

        }
        virtual ~BulbController(){
        }
};


#endif //BulbController_h