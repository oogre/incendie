import processing.sound.*;
import hypermedia.net.*;


UDP udp;  // define the UDP object


SoundFile[] files;
byte[] values;
float[] amps;

int numsounds = 384;
float toNoise = 1.0/numsounds;

int c = 0;

void setup() {
  size(1200, 400);
  udp = new UDP( this, 8800 );
 // udp.log( true );     // <-- printout the connection activity
  udp.listen( true );

  files = new SoundFile[numsounds];
  amps = new float[numsounds];
  values = new byte[numsounds];
  for (int i = 0; i < numsounds; i++) {
    files[i] = new SoundFile(this, "/Users/matierehumaine/Works/4202/MatiereHumaine/Brasseurs/incendie/sound/Incendie - mono/"+nf(i+1, 3) + ".mp3");
    files[i].loop();
    files[i].amp(0);
    files[i].rate(0.5);
    files[i].pan(noise(i * toNoise, 2, millis() * 0.001) * 2 - 1);
  }
}


void draw() {
  background(200);
  strokeWeight(2);
  for (int i = 0; i < numsounds; i++) {
    //float amp = pow(noise(i * toNoise, 0, millis() * 0.0001), 3);
    float rate = pow(noise(i * toNoise, 1, millis() * 0.00001), 3);
    float pan = noise(i * toNoise, 2, millis() * 0.0001);
    files[i].amp(amps[i]);
    files[i].rate(rate);
    files[i].pan(pan * 2 - 1);
    stroke(255, 0, 0);
    point(pan * width, i );
    stroke(0, 255, 0);
    point(amps[i] * width, i );
    stroke(0, 0, 255);
    point(rate * width, i );
  }
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler


  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);
  
  for (int i = 0; i < data.length; i++) {
    byte value = data[i];
    if(abs(values[i] - value) > 2){
      amps[i] = amps[i] * 0.9;
      //print("decrease");
    }else{
      values[i] = value;
      amps[i] = map(value, 0, 127, 1, 0);
    }
    //amps[i] = pow(amps[i] , 10);
   // print(amps[i]);print(", ");
    
  }
 // println("");
}
