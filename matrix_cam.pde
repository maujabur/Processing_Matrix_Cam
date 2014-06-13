/*
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <MauJabur> wrote this file. As long as you retain this notice you
 * can do whatever you want with this stuff. If we meet some day, and you think
 * this stuff is worth it, you can buy me a beer in return. Mau Jabur
 * ----------------------------------------------------------------------------
 */

// processing 2.2.1 2014/06/12

PFont font;
float qu, qv, du, dv, ou, ov;
float k = 1.4;
float m = 0;
boolean flip_h = false;
boolean flip_v = false;
boolean flip_r = false;

Faller[] f = new Faller[15];

import processing.video.*;

Capture video;

void keyPressed() {
  switch (key) {
  case 'h':
  case 'H':
    flip_h = !flip_h;
    break;
  case 'v':
  case 'V':
    flip_v = !flip_v;
    break;
  case 'r':
  case 'R':
    flip_r = !flip_r;
    break;
  case '+':
    if (k<6) k+=0.1;
    reset();
    break;
  case '-':
    if (k>0.5) k-=0.1;
    reset();
    break;
  }
}

void setup() {
  size (displayWidth, displayHeight, P2D);
  frameRate(20);

  video = new Capture(this, 960, 544);
  println(video.list());

  video.start();

  font = loadFont("OCRAStd-24.vlw");
  noStroke();
  
  fill(0);
  rect(0, 0, width, height);

  reset();
}

void reset() {
  textFont(font, 16*k);
  du = 10*k; 
  dv = 20*k;
  ou = 0;
  ov = 18*k;
  qu = width/du;
  qv = height/dv;
  for (int i = 0; i<f.length; i++) {
    f[i] = new Faller();
  }
}

void draw() {
  video.loadPixels();
  fill(0, 70);
  rect(0, 0, width, height);

  m = millis()/100.0;

  drawScreen();

  for (int i = 0; i<f.length; i++) {
    f[i].draw();
  }
}

void drawScreen() {
  int qy, qx;
  if (flip_r) {
    qy = video.width;
    qx = video.height;
  } else {
    qy = video.height;
    qx = video.width;
  }
  for (float v = 0; v<=qv-1; v++) {
    int y;
    if (flip_v)  y = (int)map(v, 0, qv-1, qy-1, 0);
    else         y = (int)map(v, 0, qv-1, 0, qy-1);

    for (float u = 0; u<=qu-1; u++) {
      int x;
      if (flip_h) x = (int)map (u, 0, qu-1, qx-1, 0);
      else        x = (int)map (u, 0, qu-1, 0, qx-1);

      int pixelColor;
      if (flip_r) {
        pixelColor = video.pixels[y+x*qy];
      } else {
        pixelColor = video.pixels[x+y*qx];
      }
      int g = (pixelColor >> 8) & 0xff;
      fill(0, 20+g*0.6, 0);
      //setColor(noise(u/2, v/2-m/4, m/15));
      drawChar(getChar(u, v), u, v);
    }
  }
}

char getChar(float u, float v) {
  return char( '0'+int(60*noise(u, v, m/80.0)) );
}

void drawChar (char c, float u, float v) {
  text(c, u*du+ou, v*dv+ov);
}

void setColor (float bright) {      
  fill( 80, bright*255, 40);
}

class Faller {
  float u;
  float v;
  float rate;
  char[] message = {
    'M', '@', 'u', 'J', '4', '3', 'U', 'R',
  };
  float count = 8;

  Faller() {
    reset();
    v = int(random(qv));
  }

  void update() {
    v = v+rate;
    if (v > qv+count) {
      reset();
    }
  }

  void reset() {
    v = 0;
    u = random(qu);
    rate = random(0.25, 0.4);
  }

  void draw() {
    float x =int(u);
    float y =int(v);
    for (int i = 0; i<count; i++) {
      fill(0, 0, 0, 40);
      rect(x*du+ou, (y-i)*dv+ov, du, -dv);

      if (i==0) fill( 140, 255, 120);
      else fill( 100, 155+(1.0-i/8.0)*100, 60);

      //      drawChar(getChar(x, i/10.0), x, y-i);
      drawChar(getChar(x, y-i), x, y-i);
    }
    update();
  }

  char getChar (float x, float y) {
    float offset = m/2;

    return message[int(abs(y+offset))%message.length];
  }
}

