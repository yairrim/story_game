/*********************************************************************************************/
/*********************************************************************************************/
/**************** in this window you can find the functions and the classes ******************/
/*********************************************************************************************/
/*********************************************************************************************/



//an unum to check which charecter is the bot:
enum Bot_type {
  JERBOA, 
  JERBOA_KING;
}

class Bad_gang{
 int max = 5;
 Bot[] members = new Bot[max]; 
 int dead_amount = 0;
 boolean all_dead = false;
 
 void reset(Bot_type typ){
  for(int counter = 0; counter < max; counter++){
    members[counter] = new Bot();
    members[counter].bot_initialize(typ);
  }
 }
 void gun_reset(){
  for(int counter = 0; counter < max; counter++){
    members[counter].gun = new Gun();
    members[counter].gun.initialize();
  } 
 }
 void play(Hero hero){
  this.dead_amount = 0; 
  for(int counter = 0; counter < max; counter++){
    members[counter].bot_AI(hero);
    if(members[counter].is_dead){
     this.dead_amount++; 
    }
  }
  if(this.dead_amount == max){
    this.all_dead =true;
    door.open = true;
  }
 }
}
/**********************************************************/
/**********************************************************/
/******************* class Base_object ********************/
/**********************************************************/
/**********************************************************/

//class that contains base function to use in every object:
abstract class Base_object {
  public float rotation = 0; //the rotation of the image of the object.
  abstract protected int getX(); //function that returns the x of the object.
  abstract protected int getY(); //function that returns the y of the object.
  private float speedX = 0; //variable to the vector of the x.
  private float speedY = 0; //variable to the vector of the y.
  public int speed = 0; //variable to the speed of the object.
  public int direction; //variable to the direction of the object.

  //function that changes the x of the object in accurding to both direction and speed:
  protected int advanceSpeedX() {
    int advanceX = 0;
    if (speed == 0) {
      speedX = 0;
    } else {
      speedX += (speed) * cos(radians(direction));

      advanceX = round(speedX);

      speedX = speedX - advanceX;
    }
    return advanceX;
  }
  //function that changes the y of the object in accurding to both direction and speed:
  protected int advanceSpeedY() {
    int advanceY = 0;
    if (speed == 0) {
      speedY = 0;
    } else {
      speedY += (speed) * sin(radians(direction));

      advanceY = round(speedY);

      speedY = speedY - advanceY;
    }
    return advanceY;
  }

  //function that rotates the image of the object in accurding to rotation:
  protected void rotateIt() {
    pushMatrix();
    translate(getX(), getY());
    rotate(radians(rotation));
    translate(-getX(), -getY());
    this.drawIt();
    popMatrix();
  }

  //function that draws the object:
  abstract protected void drawIt();
  public void draw() {
    this.rotateIt();
  }
}


/**********************************************************/
/**********************************************************/
/************************ class Hero **********************/
/**********************************************************/
/**********************************************************/


//the class of the object of the hero:
class Hero extends Base_object {
  private PImage image;
  private String path;
  private int x;
  private int y;
  private int object_width = -1;
  private int object_height = -1;
  public  int lifePoint = 100;
  private boolean hero_atk = false;


  protected int getX() {
    return x;
  }
  protected int getY() {
    return y;
  }
  private void setImage(String path_) {
    path = path_;
    image = loadImage(path);
    if (object_width == -1) {
      object_width = image.width;
    }
    if (object_height == -1) {
      object_height = image.height;
    }
  }
  protected void drawIt() {
    x += this.advanceSpeedX();
    y += this.advanceSpeedY();

    imageMode(CENTER);
    image(image, x, y, this.object_width, this.object_height);
  }

  //function that turn to right:
  private void turn_right() {
    this.direction += 10;
  }

  //function that turn to left:
  private void turn_left() {
    this.direction -= 10;
  }

  //function that walks backwards:
  private void walk_backward() {
    this.speed = -4;
  }


  //function that walks forward:
  private void walk_forward() {
    this.speed = 4;
  }

  private void hero_initialize() {
    this.setImage("all_Hero/hero0.png");
    this.proportion_size(22);
    this.x = width/2 - this.object_width/2;
    this.y = height/2 - this.object_height/2;
    this.direction = 270;
  }


  private void hero_play() {
    this.rotation = this.direction + 90;
    if (this.direction >= 360) {
      this.direction -= 360;
    }
    if (this.direction < 0) {
      this.direction += 360;
    }
    this.draw();
    if(this.lifePoint <= 0){
      exit();
    }
    if (this.x + this.object_width/2 > width) {
      this.x = width - this.object_width/2;
    } else if (this.x - this.object_width/2 < 0) {
      this.x = 0 + this.object_width/2;
    }

    if (this.y + this.object_width/2 > height) {
      this.y = height - this.object_width/2;
    } else if (this.y - this.object_width/2 < 0) {
      //println(this.x +"UHUH" + door.object_width + door.x);
      if(this.x < door.object_width + door.x*2 && this.x > door.x - door.object_width/2 && door.open){
        door.enter();
        println("ENTER");
      }
      this.y = 0 + this.object_width/2;
    }
    
  }

  public boolean is_point_in_shape(int x1, int y1) {
    return (this.x <= x1 && this.x + this.object_width >= x1 && this.y <= y1 && this.y + this.object_width >= y1);
  }
  private void proportion_size(int size) {
    this.object_width = int((width/100 * this.image.width/100 * size)/10);
    this.object_height = int((width/100 * this.image.height/100 * size)/10);
  }
}


/**********************************************************/
/**********************************************************/
/************************ class Bot ***********************/
/**********************************************************/
/**********************************************************/


class Bot extends Base_object {
  private PImage image;
  private String path;
  private int x;
  private int y;
  private Gun gun = null;
  private int off_set_y = (int)random(-10,10);
  private int off_set_x = (int)random(-10,10);
  private int off_set_angle = (int)random(-2,2);
  
  private int object_width = -1;
  private int object_height = -1;
  private int atack_range = 100;
  private int male_atack_damage = 20;
  private int male_attack_delay = 2;
  private int range_attack_delay = 2;
  private Time  male_attack_timer = new Time();
  private Time  range_attack_timer = new Time();
  
  private int lifePoint = 100;
  private float wanted_direction_radians;
  private int wanted_direction_degrees;
  private float y_distance_from_hero = 0;
  private float x_distance_from_hero = 0;
  private float tangents;
  private boolean is_time_reseted = false;
  private boolean is_atack_calculated = false;
  private boolean is_dead = false;

  protected int getX() {
    return x;
  }
  protected int getY() {
    return y;
  }
  private void setImage(String path_) {
    path = path_;
    image = loadImage(path);
    if (object_width == -1) {
      object_width = image.width;
    }
    if (object_height == -1) {
      object_height = image.height;
    }
  }
  protected void drawIt() {
    x += this.advanceSpeedX();
    y += this.advanceSpeedY();

    imageMode(CENTER);
    image(image, x, y, this.object_width, this.object_height);
  }

  private void bot_AI(Hero hero) {
    this.rotation = this.direction + 90 + this.off_set_angle;
    if(this.lifePoint > 0){
      this.draw();
      
      if (Math.abs(dist(hero_1.x,hero_1.y,this.x,this.y)) < 10) {
        this.speed = 0;
        male_attack(hero_1);        
      } else {
        this.speed = 1;
      }
      if( this.gun != null){
        if(Math.abs(dist(hero_1.x,hero_1.y,this.x,this.y)) < 250){
          this.shoot(); 
        }
        this.gun.update_bot(this);
      }
  
      this.turn_to_hero(hero);
      //if (this.is_in_atack_range(hero)) {
      //  if (!this.is_time_reseted) {
      //    this.time_reseter = millis();
      //    this.is_time_reseted = true;
      //  }
      //  if ((millis() - this.time_reseter % this.atack_speed) == 0) {
      //    //println(round(millis()/1000) - round(this.time_reseter/1000) % this.atack_speed);
      //    println(millis());
      //    if (!this.is_atack_calculated) {
      //      this.is_atack_calculated = true;
      //    }
      //  } else {
      //    this.is_atack_calculated = false;
      //  }
      //} else {
      //  this.is_time_reseted = false;
      //}
    }
    else{
     this.is_dead = true; 
     this.x = width + 300;
     this.y = height + 300;
    }
  }
  
  private void male_attack(Hero hero) {
    if(male_attack_timer.seconds() > this.male_attack_delay){
      hero.lifePoint -= this.male_atack_damage;
      male_attack_timer.reset();
    }
  }
  private void shoot(){
    
    this.gun.shoot(); 
  }
  public boolean is_point_in_shape(int x1, int y1) {
    return (this.x <= x1 && this.x + this.object_width >= x1 && this.y <= y1 && this.y + this.object_width >= y1);
  }
  private boolean is_in_atack_range(Hero hero) {
    if (this.x + this.object_width/2 > hero.x + hero.object_width/2 + this.atack_range) {
      return false;
    } else if (this.x + this.object_width/2 < hero.x + hero.object_width/2 - this.atack_range) {
      return false;
    }

    if (this.y + this.object_height/2 > hero.y + hero.object_height/2 + this.atack_range) {
      return false;
    } else if (this.y + this.object_height/2 < hero.y + hero.object_height/2 - this.atack_range) {
      return false;
    } else {
      return true;
    }
  }


  private void bot_initialize(Bot_type type) {
    this.speed = 0;
    if (type == Bot_type.JERBOA) {
      this.setImage("jerboa.png");
    }
    this.proportion_size(20);
    this.x = (int)random(width);
    this.y = (int)random(height/2,height);
  }

  private void turn_to_hero(Hero hero) {
    this.y_distance_from_hero = this.y - hero.y;
    this.x_distance_from_hero = this.x - hero.x;
    this.tangents = this.y_distance_from_hero/this.x_distance_from_hero;
    this.wanted_direction_radians = atan(tangents);
    this.wanted_direction_degrees = int (degrees(this.wanted_direction_radians));
    if (this.x < hero.x) {
      this.direction = this.wanted_direction_degrees;
    } else {
      this.direction = this.wanted_direction_degrees + 180;
    }
  }

  private void proportion_size(int size) {
    this.object_width = int((width/100 * this.image.width/100 * size)/10);
    this.object_height = int((width/100 * this.image.height/100 * size)/10);
  }
}


/**********************************************************/
/**********************************************************/
/********************** class Sword ***********************/
/**********************************************************/
/**********************************************************/
class Sword extends Base_object {
  private PImage image;
  private String path;
  private int x;
  private int y;
  private int object_width = -1;
  private int object_height = -1; 
  private int swing_damage = 10;
  private int stab_damage = 15;
  private int extra_damage = 0;
  private boolean show_graphics = false;
  private boolean in_stab = false;
  private int time;
  private boolean time_rested = false;

  protected int getX() {
    return x;
  }
  protected int getY() {
    return y;
  }
  private void setImage(String path_) {
    path = path_;
    image = loadImage(path);
    if (object_width == -1) {
      object_width = image.width;
    }
    if (object_height == -1) {
      object_height = image.height;
    }
  }
  protected void drawIt() {
    x += this.advanceSpeedX();
    y += this.advanceSpeedY();

    imageMode(CORNER);
    image(image, x, y, this.object_width, this.object_height);
  }

  private void sword_initialize() {
    this.speed = 0;
    this.setImage("sword.png");
    this.proportion_size(50);
    this.x = width/2;
    this.y = height/2;
  }


  private void go_to_user(Bot bot) {
    float cos_bot = cos(radians(bot.direction));
    float sin_bot = sin(radians(bot.direction));
    int hypotenuse = bot.object_height/2;
    float opposite = sin_bot * hypotenuse;
    float adjacent = cos_bot * hypotenuse;
    this.direction = bot.direction;
    this.x = int(bot.x + adjacent);
    this.y = int(bot.y + opposite);
  }

  private void go_to_user(Hero hero) {
    float cos_hero = cos(radians(hero.direction - 90));
    float sin_hero = sin(radians(hero.direction - 90));
    int hypotenuse = hero.object_width/2 - this.object_width/2;
    float opposite = sin_hero * hypotenuse;
    float adjacent = cos_hero * hypotenuse;
    if (!hero.hero_atk) {
      this.direction = hero.direction;
    }
    this.x = int(hero.x + adjacent);
    this.y = int(hero.y + opposite);
  }


  private void proportion_size(int size) {
    this.object_width = int((width/100 * this.image.width/100 * size)/10);
    this.object_height = int((width/100 * this.image.height/100 * size)/10);
  }
}


/**********************************************************/
/**********************************************************/
/********************** class Point ***********************/
/**********************************************************/
/**********************************************************/
class Bullet extends Base_object{
  public int x;
  public int y;
  public int bullet_speed = 7;
  public int radius_x;
  public int radius_y;
  public color brush;
  public int alpha = 255;
  public color pen;
  public boolean hit = false;
  public boolean firing = false;
  public int penThickness;
  public boolean shot = false;

  protected void drawIt() {
    brush = (brush & 0xffffff) | (alpha << 24);
    pen = (pen & 0xffffff) | (alpha << 24);
    fill(brush);
    if (penThickness == 0) {
      noStroke();
    } else {
      strokeWeight(penThickness);
      stroke(pen);
    }
    x += this.advanceSpeedX();
    y += this.advanceSpeedY();
    ellipse(x, y, radius_x * 2, radius_y * 2);
  }

  protected int getX() {
    return x;
  }

  protected int getY() {
    return y;
  }

  public boolean pointInShape(int x1, int y1) {
    double normalizeXPow2 = pow((x1 - x), 2);
    double normalizeYPow2 = pow((y1 - y), 2);
    double radius_xPow2 = pow(radius_x, 2);
    double radius_yPow2 = pow(radius_y, 2);
    return ((normalizeXPow2 / radius_xPow2) + (normalizeYPow2 / radius_yPow2)) <= 1.0;
  }

  
  private boolean off_screen(){
    return (this.x > width || this.x < 0 || this.y > height || this.y < 0);
  }
  
  private void initialize(){
    this.x = 0;
    this.y = 0;
    this.radius_x = 5;
    this.radius_y = 5;
    this.brush = color(0, 0, 0);
  }
  
  private void update(Gun gun){
    if(!shot){
      this.direction = gun.direction;
      this.x = width+100;
      this.y = height+100;
    }
    else{
     this.speed = bullet_speed; 
    }
    if(hit || off_screen()){
     this.speed = 0;
     this.x = width+100;
     this.y = height+100; 
    }
    
    this.draw();
  }
}



/**********************************************************/
/**********************************************************/
/********************** class Point ***********************/
/**********************************************************/
/**********************************************************/
class Point {
  int x;
  int y;
  boolean show = false;
  Point(int x_, int y_) {
    x = x_;
    y = y_;
  }
  void draw() {
    point(x, y);
  }
}


/**********************************************************/
/**********************************************************/
/*********************** class Time ***********************/
/**********************************************************/
/**********************************************************/
class Time{
  int time = 0;
  
  public void reset(){
    time = millis();
  }
  
  public int millis(){
    return (millis() - time);
  }
  
  public float seconds(){
    return ((millis() - time)/1000);
  }
}

/**********************************************************/
/**********************************************************/
/****************** class Main_functions ******************/
/**********************************************************/
/**********************************************************/
class Main_functions {
  private void reset(int lvl) {
    door.open = false;
    bg = loadImage("data/background.jpg");
    bg.resize(width, height);
    //player_sword.sword_initialize();
    //bot_sword.sword_initialize();
    hero_1.hero_initialize();
    gun_hero.initialize();
    door.initialize();
    //player_hand.hand_initialize(hero_1);
    switch(lvl){
      case 1:
        bad_gang.reset(Bot_type.JERBOA);
        break;
      case 2: 
        bad_gang.reset(Bot_type.JERBOA);
        bad_gang.gun_reset();
        break;
      case 3:
        bad_gang.reset(Bot_type.JERBOA);
        bad_gang.gun_reset();
        break;
    }
    
  }

  private void main_loop() {
    background(bg);
    //player_sword.sword_play(hero_1);
    //bot_sword.sword_play(bad_guy);
    //player_hand.hand_play(hero_1);
    bad_gang.play(hero_1);
    gun_hero.update_hero();
    hero_1.hero_play();
    door.play();
    //////////sword_line_left.place_line(bot_sword);
  }
  private void key_events() {
    if (key == 'd') {
      hero_1.turn_right();
    }

    if (key == 'a') {
      hero_1.turn_left();
    }

    if (key == 's') {
      hero_1.walk_backward();
    }

    if (key == 'w') {
      hero_1.walk_forward();
    }
    
    if(key == ' '){
      if(!gun_hero.single_shot){
        gun_hero.shoot();
        gun_hero.single_shot = true;
      }
    }
  }

  private void key_release() {
    player_hand.object_height = 1;
    hero_1.speed = 0;
    hero_1.hero_atk = false;
    gun_hero.single_shot = false;
  }
}


class Door extends Base_object {
  public int x;
  public int y;
  public int object_width;
  public int object_height;
  public int originalWidth = -1;
  public int originalHeight = -1;
  public color brush;
  public int alpha = 255;
  public color pen;
  public int penThickness;
  boolean open = false;

  protected void drawIt() {
    brush = (brush & 0xffffff) | (alpha << 24);
    pen = (pen & 0xffffff) | (alpha << 24);
    fill(brush);
    if (penThickness == 0) {
      noStroke();
    } else {
      strokeWeight(penThickness);
      stroke(pen);
    }

    x += this.advanceSpeedX();
    y += this.advanceSpeedY();
    rectMode(CENTER);
    rect(x, y, object_width, object_height);
  }

  protected int getX() {
    return x;
  }

  protected int getY() {
    return y;
  }

  private void initialize() {
    this.object_width = 200;
    this.object_height = 15;
    this.x = width/2;
    this.y = 0 + this.object_height/2;
    this.brush = color(240,10,15);
  }

  private void enter() {
     level++;
     hero_1.x = width/2;
     hero_1.y = height/2;
     main_functions.reset(level);

  }
  private void play() {
    if(this.open){
     this.brush = color(10,240,15); 
    }
    this.draw();
  }

}





class Rect extends Base_object {
  public int x;
  public int y;
  public int object_width;
  public int object_height;
  public int originalWidth = -1;
  public int originalHeight = -1;
  public color brush;
  public int alpha = 255;
  public color pen;
  public int penThickness;

  protected void drawIt() {
    brush = (brush & 0xffffff) | (alpha << 24);
    pen = (pen & 0xffffff) | (alpha << 24);
    fill(brush);
    if (penThickness == 0) {
      noStroke();
    } else {
      strokeWeight(penThickness);
      stroke(pen);
    }

    x += this.advanceSpeedX();
    y += this.advanceSpeedY();

    rect(x, y, object_width, object_height);
  }

  protected int getX() {
    return x;
  }

  protected int getY() {
    return y;
  }

  private void hand_initialize(Hero hero) {
    this.object_width = player_sword.object_width/3;
    this.object_height = 1;
    this.x = 0;
    this.y = 0;
    this.brush = color(58, 58, 60);
  }

  private void hand_play(Hero hero) {
    this.go_to_user(hero);
    this.rotation = this.direction + 270;
    this.draw();
  }

  private void go_to_user(Hero hero) {
    float cos_hero = cos(radians(hero.direction - 90));
    float sin_hero = sin(radians(hero.direction - 90));
    int hypotenuse = hero.object_width/2;
    float opposite = sin_hero * hypotenuse;
    float adjacent = cos_hero * hypotenuse;
    if (!hero.hero_atk) {
      this.direction = hero.direction;
    }
    this.x = int(hero.x + adjacent);
    this.y = int(hero.y + opposite);
  }
  private void proportion_size(int width, int height) {
    this.object_width = int((width/100  * width)/10);
    this.object_height = int((width/100  * height)/10);
  }
}




/********************************************/
/***  Class Line                          ***/
/********************************************/
class Line extends Base_object {
  public int x1;
  public int y1;
  public int x2;
  public int y2;
  public int alpha = 255;
  public color pen = color(50,255,120,50);
  public int penThickness = 4;

  protected void drawIt() {
    //brush = (brush & 0xffffff) | (alpha << 24);
    pen = (pen & 0xffffff) | (alpha << 24);
    if (penThickness == 0) {
      noStroke();
    } else {
      strokeWeight(penThickness);
      stroke(pen);
    }
    int advancedSpeedX = this.advanceSpeedX();
    int advancedSpeedY = this.advanceSpeedY();
    x1 += advancedSpeedX;
    y1 += advancedSpeedY;
    x2 += advancedSpeedX;
    y2 += advancedSpeedY;
    line(x1, y1, x2, y2);
  }
  protected int getX() {
    return x1;
  }
  protected int getY() {
    return y1;
  }

  boolean circleIntersect(int x, int y, int radius) {
    return circleLineIntersect(this.x1, this.y1, this.x2, this.y2, x, y, radius);
  }

  void place_line(Sword sword){
    int hypotenuse = sword.object_height;
    float cosinus = cos(radians(sword.direction - 90));
    float sinus = sin(radians(sword.direction - 90));
    float tangent = tan(radians(sword.direction - 90));
    float adjacent = cosinus * hypotenuse;
    float opposite = sinus * hypotenuse;
    this.x2 = int(sword.x - (10 / cosinus));
    this.y2 = int(sword.y + (10 / sinus));
    
    this.x1 = int(sword.x - opposite - (10 / cosinus));
    this.y1 = int(sword.y + adjacent + (10 / sinus));    
    this.draw();
  }
}

boolean circleLineIntersect(float x1, float y1, float x2, float y2, float cx, float cy, float cr) {
  float dx = x2 - x1;
  float dy = y2 - y1;
  float a = dx * dx + dy * dy;
  float b = 2 * (dx * (x1 - cx) + dy * (y1 - cy));
  float c = cx * cx + cy * cy;
  c += x1 * x1 + y1 * y1;
  c -= 2 * (cx * x1 + cy * y1);
  c -= cr * cr;
  float bb4ac = b * b - 4 * a * c;

  //println(bb4ac);

  if (bb4ac < 0) {  // Not intersecting
    return false;
  } else {

    float mu = (-b + sqrt( b*b - 4*a*c )) / (2*a);
    float ix1 = x1 + mu*(dx);
    float iy1 = y1 + mu*(dy);
    mu = (-b - sqrt(b*b - 4*a*c )) / (2*a);
    float ix2 = x1 + mu*(dx);
    float iy2 = y1 + mu*(dy);

    // The intersection points
    //ellipse(ix1, iy1, 10, 10);
    //ellipse(ix2, iy2, 10, 10);

    float testX;
    float testY;
    // Figure out which point is closer to the circle
    if (dist(x1, y1, cx, cy) < dist(x2, y2, cx, cy)) {
      testX = x2;
      testY = y2;
    } else {
      testX = x1;
      testY = y1;
    }

    if (dist(testX, testY, ix1, iy1) < dist(x1, y1, x2, y2) || dist(testX, testY, ix2, iy2) < dist(x1, y1, x2, y2)) {
      return true;
    } else {
      return false;
    }
  }
}


class Gun extends Base_object {
  private PImage image;
  private String path;
  private int x;
  private int off_set;
  private int y;
  private int object_width = -1;
  private int object_height = -1;
  public  int ammo_max = 5;
  public boolean hit = false;
  public boolean hit_calculated = false;
  private boolean single_shot = false;
  Bullet[] ammo = new Bullet[ammo_max];
  

  protected int getX() {
    return x;
  }
  protected int getY() {
    return y;
  }
  private void setImage(String path_) {
    path = path_;
    image = loadImage(path);
    if (object_width == -1) {
      object_width = image.width;
    }
    if (object_height == -1) {
      object_height = image.height;
    }
  }
  protected void drawIt() {
    x += this.advanceSpeedX();
    y += this.advanceSpeedY();

    imageMode(CENTER);
    image(image, x, y, this.object_width, this.object_height);
  }
  
  public void initialize(){
    this.setImage("data/boat.png");
    this.proportion_size(25);
    for(int counter = 0; counter < ammo_max; counter++){
      ammo[counter] = new Bullet();
      ammo[counter].initialize();
    }
  }
  public void update_hero(){
    this.x = hero_1.x;
    this.y = hero_1.y;
    this.direction = hero_1.direction;
    this.rotation = this.direction - 135;
    for(int counter = 0; counter < ammo_max; counter++){
      ammo[counter].update(this);
    }
    for(int counter = 0; counter < bad_gang.max; counter++){
      hit(bad_gang.members[counter]);
    }
    this.draw();
  }
  
  public void update_bot(Bot owner){
    this.x = owner.x;
    this.y = owner.y;
    this.off_set = (int)random(-23,23);
    this.direction = owner.direction + this.off_set;;
    this.rotation = this.direction - 135 - this.off_set;
    for(int counter = 0; counter < ammo_max; counter++){
      ammo[counter].update(this);
    }
    hit(hero_1);
    this.draw();
  }
  public void hit(Bot bot) {
    for(int counter = 0; counter < ammo_max; counter++){
      if(bot.is_point_in_shape(ammo[counter].x,ammo[counter].y) && bot.lifePoint > 0){
        if(!ammo[counter].hit){
          bot.lifePoint -=15;
        }
        ammo[counter].hit = true; 
        println(bot.lifePoint);
      }
      else{
        ammo[counter].hit = false;
      }  
    }
  }
  
  public void hit(Hero hero) {
    for(int counter = 0; counter < ammo_max; counter++){
      if(hero.is_point_in_shape(ammo[counter].x,ammo[counter].y) && hero.lifePoint > 0){
        if(!ammo[counter].hit){
          hero.lifePoint -=15;
        }
        ammo[counter].hit = true;
      }
      else{
        ammo[counter].hit = false;
      }  
    }
  }
  public void shoot(){
   for(int counter = 0; counter < ammo_max; counter++){
      if(!ammo[counter].shot){
        ammo[counter].shot = true;
        ammo[counter].x = this.x;
        ammo[counter].y = this.y;
        break;
      }
      else if(counter == 4 && ammo[counter].x > width && ammo[counter].y > height){
        this.reload();  
      }
    }
  }
  public void reload(){
    for(int counter = 0; counter < ammo_max; counter++){
      ammo[counter].shot = false;
      ammo[counter].firing = false;
    } 
  }


  private void proportion_size(int size) {
    this.object_width = int((width/100 * this.image.width/100 * size)/10);
    this.object_height = int((width/100 * this.image.height/100 * size)/10);
  }
}
