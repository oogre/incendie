import hypermedia.net.*;
import codeanticode.syphon.*;
import java.util.List;
UDP udp;  // define the UDP object


SyphonClient client;

int port = 8888;
String ip ="192.168.1.255";

byte[] buffer;
PGraphics img;
ArrayList<Sensor> sensors;
int bulbLen = 1000;

static float z = 0;
void setup() {
  size(1920, 1080, P3D);
  udp = new UDP( this, 6000 );
  
  sensors = new  ArrayList<Sensor>();
  
  buffer = new byte[bulbLen];
  
  
  
  for (int i = 0; i < bulbLen; i ++ ) {
    PVector p;
    while(true){
      p = new PVector(
        random(Sensor.radius , width - Sensor.radius), 
        random(Sensor.radius , height - Sensor.radius), 
        random(-height/2, height/2)
       );
      boolean isValid = true;
      for (Sensor sensor : sensors) {
        isValid = !sensor.isHover(p);
        if(!isValid)break;
      }
      if(isValid)break;
    }
    sensors.add(new Sensor(this, p)) ;
  }
  HashMap [] list = SyphonClient.listServers();
  if (list.length > 0) {
    client = new SyphonClient(this, "", (String)list[0].get("ServerName"));
  }
}

void draw() {
  background(255);
  
  if (client != null && client.newFrame()) {
    img = client.getGraphics(img);
    image(img, 0, 0, width, height);
  }

  translate(0, 0, z);
  PVector mouse = new PVector(mouseX, mouseY, -z);
  for (Sensor sensor : sensors) {
    sensor.update(mouse, mousePressed);
    buffer[sensor.id] = sensor.draw();
  }
  udp.send( buffer, ip, port );
}

void mouseWheel(MouseEvent event) {
  z += event.getCount();
  
}

static class Sensor {
  static int COUNTER;
  static Sensor grabbedItem;
  int id;
  PVector position;
  static int radius = 7;
  PApplet parent;
  boolean grabbed = false;
  boolean hover = false;
  Sensor(PApplet parent, PVector position) {
    id = COUNTER++;
    this.parent = parent;
    this.position = position;
  }

  float sigmoid (float x) {
    return exp(x) / (exp(x) + 1);
  };

  boolean isHover(PVector p) {
    return PVector.sub(p, position).magSq() < (radius*2) * (radius*2) ;
  }

  void update(PVector p, boolean grab) {
    hover = isHover(p);
    if ( grabbed || (Sensor.grabbedItem==null && grab && hover)) {
      grabbed = true;
      position.set(p.x, p.y, position.z);
      grabbedItem = this;
    }
    if (!grab && Sensor.grabbedItem!=null) {
      grabbed = false;
      grabbedItem = null;
    }
  }
  
  byte draw() {
    float alpha = 255;
    if(abs(position.z - z) > radius) alpha = 12;
    this.parent.rectMode(CENTER);
    this.parent.noFill();
    this.parent.pushMatrix();
    this.parent.translate(position.x, position.y, position.z);
    if (hover || grabbed) {
      this.parent.stroke(255, 0, 0);
      this.parent.box(radius * 2 + 2);
    }
    this.parent.stroke(255, alpha);
    this.parent.box(radius * 2);
    this.parent.stroke(0, alpha);
    this.parent.box(radius * 2 - 2);
    this.parent.popMatrix();
    return 0;
    //int c = this.parent.get((int)position.x, (int)position.y);
    //int r = c >> 16 & 0xFF;
    //int g = c >> 8 & 0xFF;
    //int b = c >> 0 & 0xFF;
    //float l = (0.299*r + 0.587*g + 0.114*b) / 255;
    //return byte(round(sigmoid(l * 12 - 6) * 255));
  }
}
