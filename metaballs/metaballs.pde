import java.util.ArrayList;

public static final float GRAVITY = .2f;

public class Metaball {
  color col;
  double radius;
  PVector pos;
  
  public Metaball(color c, double x, double y, double r) {
    this.col = c;
    pos = new PVector((float)x,(float)y);
    radius = r;
  }
  
  //Euclidean distane, threshhold of ~.1f works well
  public float f(PVector x) {
    return (float)(radius/(PVector.sub(x,pos)).magSq());
  }

  //Manhattan distance, threshhold of ~.2f works well
  public float g(PVector x) {
    double denom  = Math.max(abs(pos.x-x.x),abs(pos.y-x.y));
    return (float) (radius/(denom*denom));
  }
  
}

public class GravBall {
  double mass;
  PVector vel;
  Metaball ball;
  
  public GravBall(Metaball ball, PVector velocity, double mass){
    vel = velocity;
    this.ball = ball;
    this.mass = mass;
  }
}

public class BallBag {
  ArrayList<GravBall> balls;
  
  public BallBag() {
    this.balls = new ArrayList<GravBall>();
  }
  
  public void addBall(GravBall b){
    balls.add(b);
  }
  
  public void update() {
    for (GravBall b1:balls){
      for (GravBall b2:balls){
        if (!b1.equals(b2)){
          double mag = GRAVITY*b1.mass*b2.mass/(PVector.sub(b1.ball.pos,b2.ball.pos).magSq());
          if (mag != mag){
            mag = .01;
          } 
          mag = Math.min(mag,10);
          PVector dir = PVector.sub(b2.ball.pos,b1.ball.pos);
          dir.normalize();
          dir.mult((float)mag);
          b1.vel.add(dir);
        }
      }
    }
    for (GravBall b: balls){
      b.ball.pos.add(b.vel);
    }
  }
  
  public void draw() {
    loadPixels();
    for (int x = 0; x < width; x++){
      for (int y = 0; y < height; y++){
        float val = 0;
        for (GravBall b: balls){
          val += b.ball.f(new PVector(x,y));
        }
        if (val > threshhold) {
          pixels[y*width+x] = color(30,100,(int)(Math.sqrt(val)*100));
        }
        else{
          pixels[y*width+x] = color(0,0,0);
        }
      }
    }
    updatePixels();
  }
  
  public void gravWell(PVector pos, float mass){
    for (GravBall b: balls){
      double mag = GRAVITY*b.mass*mass/(PVector.sub(b.ball.pos,pos).magSq());
          if (mag != mag){
            mag = .01;
          } 
          mag = Math.min(mag,10);
          PVector dir = PVector.sub(pos,b.ball.pos);
          dir.normalize();
          dir.mult((float)mag);
          b.vel.add(dir);
    }
  }
  
  public void addRandomBall(){
    bb.addBall(new GravBall(new Metaball(color(0,0,0),random(width),random(height),50 + random(150)),new PVector(0,0),50 + random(200)));
  }
  
  public void addRandomNegBall(){
    bb.addBall(new GravBall(new Metaball(color(0,0,0),random(width),random(height),-50 - random(150)),new PVector(0,0),50 + random(200)));
  }
  
}

BallBag bb;
double threshhold = .03f;

void setup(){
  size(640,480);
  frameRate(30);
  colorMode(HSB, 100);
  bb = new BallBag();
  for (int i = 0; i < 5; i++){
    bb.addRandomBall();
    //bb.addRandomNegBall();
  }
}


void draw(){
  System.out.println("Update");
  bb.update();
  bb.gravWell(new PVector(width/2,height/2),2000);
  System.out.println("Draw");
  bb.draw();
}
