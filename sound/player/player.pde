import processing.sound.*;

SoundFile[] files;
byte[] amps;

int numsounds = 384;
float toNoise = 1.0/numsounds;

int c = 0;

void setup() {
  size(1200, 400);
  files = new SoundFile[numsounds];
  amps = new byte[numsounds];

  for (int i = 0; i < numsounds; i++) {
    files[i] = new SoundFile(this, "/Users/matierehumaine/Works/4202/MatiereHumaine/Brasseurs/incendie/sound/Incendie - mono/"+nf(i+1, 3) + ".mp3");
    files[i].loop();
    files[i].amp(pow(noise(i * toNoise, 0, millis() * 0.0001), 5));
    files[i].rate(noise(i * toNoise, 1));
    files[i].pan(noise(i * toNoise, 2, millis() * 0.001) * 2 - 1);
  }
}


void draw() {
  background(200);
  strokeWeight(2);
  for (int i = 0; i < numsounds; i++) {
    float amp = pow(noise(i * toNoise, 0, millis() * 0.0001), 3);
    float rate = pow(noise(i * toNoise, 1, millis() * 0.00001), 3);
    float pan = noise(i * toNoise, 2, millis() * 0.0001);
    files[i].amp(amp);
    files[i].rate(rate);
    files[i].pan(pan * 2 - 1);
    stroke(255, 0, 0);
    point(pan * width, i );
    stroke(0, 255, 0);
    point(amp * width, i );
    stroke(0, 0, 255);
    point(rate * width, i );
    
  }
}
