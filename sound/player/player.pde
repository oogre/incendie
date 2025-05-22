import processing.sound.*;
<<<<<<< HEAD
=======

>>>>>>> d06a55706938c56e5441ffd8ce8dc544cd8ac6ec
import hypermedia.net.*;


UDP udp;  // define the UDP object


Sample[] files;
byte[] values;
float[] amps;
long [] stopAt;
boolean [] wasPlaying;

int numsounds = 200;
float toNoise = 1.0/numsounds;


int c = 0;

void setup() {
  size(1200, 400);
  udp = new UDP( this, 8800 );
  //udp.log( true );     // <-- printout the connection activity
  udp.listen( true );

  files = new SoundFile[numsounds];
  amps = new float[400];
  values = new byte[400];
  for (int i = 0; i < numsounds; i++) {
    files[i] = new SoundFile(this, "C:/Users/vince/Desktop/Incendie/incendie/sound/Incendie - mono/"+nf(i+1 + 150, 3) + ".mp3");
    files[i].loop();
    files[i].amp(0);
    files[i].rate(0.75);
    files[i].pan(noise(i * toNoise, 2, millis() * 0.001) * 2 - 1);
    wasPlaying[i] = false;
  }
}


void draw() {
  background(0);
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

    amps[i] += (0 - amps[i] ) * 0.01;
  }
   
}

void receive( byte[] data, String ip, int port ) {  // <-- extended handler


  // get the "real" message =
  // forget the ";\n" at the end <-- !!! only for a communication with Pd !!!
  data = subset(data, 0, data.length-2);

  for (int i = 0; i < data.length; i++) {
    byte value = data[i];
    if (abs(values[i] - value) < 5) {
      //amps[i] = amps[i] * 0.05;
      //print("decrease");
    } else {
      values[i] = value;
      amps[i] += (map(value, 0, 127, 0.5, 0) - amps[i]) * 0.01;
    }
    //amps[i] = pow(amps[i] , 10);
    // print(amps[i]);print(", ");
  }
  println("");
}
