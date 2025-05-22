class Sample extends SoundFile{
  long timeDelay = 1000;
  long timeAtStart;
  float _rate = 1;
  Sample(PApplet parent, String address){
    super(parent, address);
    super.rate(_rate);
  }
  
  boolean is_pLaying() {
    println(super.position()* _rate, super.duration());
    return (super.position()* _rate) - timeDelay > super.duration() ;
  }
  
  void setRate(float r){
    super.rate(r);
    _rate = r;
  }
  
}
