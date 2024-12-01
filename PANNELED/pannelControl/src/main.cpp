#include <Arduino.h>
/* Derived from Adafruit RGB_matrix_Panel library */

#include <Adafruit_GFX.h>   // Core graphics library
#include <P3RGB64x32MatrixPanel.h>

// constructor with default pin wiring
P3RGB64x32MatrixPanel matrix;



// Input a value 0 to 24 to get a color value.
// The colours are a transition r - g - b - back to r.
uint16_t Wheel(byte WheelPos) {
  if(WheelPos < 8) {
   return matrix.color444(15 - WheelPos*2, WheelPos*2, 0);
  } else if(WheelPos < 16) {
   WheelPos -= 8;
   return matrix.color444(0, 15-WheelPos*2, WheelPos*2);
  } else {
   WheelPos -= 16;
   return matrix.color444(0, WheelPos*2, 7 - WheelPos*2);
  }
}


// use this constructor for custom pin wiring instead of the default above
// these pins are an example, you may modify this according to your needs
//P3RGB64x32MatrixPanel matrix(25, 26, 27, 21, 22, 23, 15, 32, 33, 12, 16, 17, 18);

void setup() {

 matrix.begin();
  Serial.begin(115200);
}
float c = 0;
void loop(){ 
  
  auto l = matrix.color444(8, 5, 4);
  auto n = matrix.color444(0, 0, 0);
  
  c += 0.1f;
  
  Serial.println(c);
  // Serial.println(sizeof(b)/sizeof(uint8_t));
  // Serial.println(b[c]);
  // Serial.println("");

 for(uint16_t i = 0 ; i < 2048 ; i ++){
  if(fmod(i, c) < 0.01f)
    matrix._matrixbuff[0].data()[i] = l;
  else
    matrix._matrixbuff[0].data()[i] = n;
 }

  // if(g){
  //   for(uint8_t y = 0 ; y < 32 ; y ++){
  //     for(uint8_t x = 0 ; x < 64 ; x ++){
  //       uint8_t t = millis()%2 == 0;
  //       if((x % 2 == 0 && y % 2 == 0)  || (x % 2 == 1 && y % 2 == 1))

  //         matrix._matrixbuff[0].data()[x + y * 64] = t * matrix.color444(8, 5, 4);
  //         // matrix.drawPixel( x, y, t * matrix.color444(8, 5, 4))  ;
  //       else
  //         // matrix.drawPixel( x, y, (1-t) * matrix.color444(8, 5, 4))  ;
  //         matrix._matrixbuff[0].data()[x + y * 64] = (1-t) * matrix.color444(8, 5, 4);

  //     }
  //   }
  // }
  // else{
  //   for(uint8_t x = 0 ; x < 64 ; x ++){
  //     for(uint8_t y = 0 ; y < 32 ; y ++){
  //       uint8_t t = millis()%2 == 0;
  //       if((x % 2 == 0 && y % 2 == 0)  || (x % 2 == 1 && y % 2 == 1))
  //         matrix.drawPixel( x, y, t * matrix.color444(8, 5, 4))  ;
  //       else
  //         matrix.drawPixel( x, y, (1-t) * matrix.color444(8, 5, 4))  ;

  //     }
  //   }
  // }
//  matrix.drawPixel( 20, 20, matrix.color444(15, 15, 15))  ;
 

// matrix.endWrite()


}

