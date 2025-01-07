#ifndef Simulacre_h
#define Simulacre_h

#include "BaseLeaf.h"
#include "BulbController.h"

class Simulacre : public BaseLeaf{
    uint32_t t0;
    float cycle = 1.0/(1000 * 60 * 60);
    public :
        Simulacre()
        : BaseLeaf(){
            t0 = millis();
        }

        virtual ~Simulacre(){
        }

        bool update(){
            float offset = sin((millis() - t0) * cycle * 11 * TWO_PI) * 5 + 5;
            float baseLum = sin((millis() - t0) * cycle * TWO_PI) * 0.4 + 0.5 + (random(-offset, offset)*0.01);
            Serial.println(baseLum);
            BulbController::setLum(int(baseLum*255));
            return true;
        }

};


#endif // Simulacre_h