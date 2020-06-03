
import java.util.ArrayList;
import java.util.List;


// Word to convert to points:
String word = "HELLO";

// Desired font (either built-in font or custom one from "customFonts" folder):
//String fontName = "Georgia";  // built-in example
String fontName = "OpenSans-Regular.ttf";  // custom example
boolean usingCustomFont = true;  // toggle whether using built-in or custom font
int fontSize = 100;  // make smaller or bigger if word doesn't fit on screen


PrintWriter file;
PFont font;

boolean start = false;
color c;
List<PVector> points = new ArrayList<PVector>();

void setup() {
  if (usingCustomFont) {
    font = createFont("customFonts/" + fontName, fontSize);
  } else {
    font = createFont(fontName, fontSize);
  }
  textFont(font);
  fullScreen();
  file = createWriter("textFiles/"+word+"_"+fontName+".txt");
}

List<PVector> grabPts() {
  List<PVector> output = new ArrayList<PVector>();
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      if (checkPix(x, y)) {
        output.add(new PVector(x, y));
      }
    }
  }
  return output;
}

color get2(int x, int y) {
  loadPixels();
  if (x >= 0 && y >= 0 && x < width && y < height) {
    return pixels[width*y + x];
  } else {
    return pixels[width*2+3];
  }
}

boolean checkPix(int x, int y) {
  if (!(x >= 1 && y >= 1 && x < width-1 && y < height-1)) {
    return false;
  }
  if (get(x, y) == c) {
    if (get(x - 1, y) != c || get(x, y - 1) != c || get(x + 1, y) != c || get(x, y + 1) != c) {
      return true;
    }
  }
  return false;
}

List<PVector> sortt() {
  List<PVector> output = new ArrayList<PVector>();
  output.add(new PVector(textWidth(word)+20, textAscent()+height-20));
  output.add(points.get(points.size() - 1));
  while (points.size() > 0) {
    PVector curr = output.get(output.size() - 1);
    float minimum = 1000000;
    int newCurrInd = 0;
    PVector newCurr = new PVector(0, 0);
    for (int i = 0; i < points.size(); i++) {
      PVector p = points.get(i);
      float newDist = curr.dist(p);
      if (newDist < minimum) {
        newCurrInd = i;
        newCurr = p;
        minimum = newDist;
      }
    }
    output.add(newCurr);
    points.remove(newCurrInd);
  }
  PVector transl = new PVector(20, height - textDescent()-20);
  for (PVector p : output) {
    p.sub(transl);
  }
  return output;
}


void draw() {
  background(255);
  stroke(0);
  fill(0);
  textFont(font);
  if (!start) {
    background(0);
    loadPixels();
    c = pixels[0];
    background(255);
    text(word, 20, height-textDescent()-20);
    points = grabPts();
    points = sortt();
    start = true;
  }
  translate(20, height-textDescent()-20);
  strokeWeight(8);
  point(0,0);
  strokeWeight(3);
  for (int i = 0; i < points.size(); i++) {
    if (i % 1 == 0) {
      PVector p = points.get(i);
      point(p.x, p.y);
      file.println(p);
    }
  }
  noFill();
  strokeWeight(1);
  rect(0,textDescent(),points.get(0).x,-points.get(0).y);
  noLoop();
}

void keyPressed() {
  file.flush();
  file.close();
  exit();
}
