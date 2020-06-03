
import java.util.ArrayList;
import java.util.List;

import peasy.*;


// Words: (have to run these words through "get_points_from_font.pde" before using them here)
String word1 = "Sideview";
String word2 = "Generator";

// Desired font: (must match the font used in "get_points_from_font.pde" for the 2 words)
//String fontName = "Georgia";  // built-in example
String fontName = "OpenSans-Regular.ttf";  // custom example
boolean usingCustomFont = true;  // toggle whether using built-in or custom font
// mess with these in order to get the best mapping of points between the two words:
int fontSize1 = 100;
int fontSize2 = 100;

// Angle between the two words:
float angle2 = -PI/3;  // (angle is first minus second)

// How far away the camera is: (default is 800 - works best for most words)
int away = 800;

// Density of points: (default is 5)
int density = 5;

// Accuracy of points: (how closely they match the words, default is 1)
int dista = 1;  // larger dista = less accuracy

// Toggle whether the whole system is spinning
boolean spinning = false;


PeasyCam cam;
CameraState state2;

PFont font;

String fileName1 = "get_points_from_font/textFiles/"+word1+"_"+fontName+".txt";
String fileName2 = "get_points_from_font/textFiles/"+word2+"_"+fontName+".txt";

List<PVector> points1;
List<PVector> points2;
List<Line> lines1 = new ArrayList<Line>();
List<Line> lines2 = new ArrayList<Line>();
List<PVector> points = new ArrayList<PVector>();
int last;
boolean inState1 = true;
float angle = 0;

void setup() {
  fullScreen(P3D);
  cam = new PeasyCam(this,away);
  cam.setMaximumDistance(4500);
  cam.setResetOnDoubleClick(false);
  cam.setRotations(0, -angle2, 0);
  state2 = cam.getState();
  cam.reset(0);
  strokeWeight(3);
  points1 = parseFile(fileName1);
  points2 = parseFile(fileName2);
  if (usingCustomFont) {
    fontName = "get_points_from_font/customFonts/" + fontName;
  }
  font = createFont(fontName, fontSize1);
  textFont(font);
  centerResize(points1, word1);
  font = createFont(fontName, fontSize2);
  textFont(font);
  centerResize(points2, word2);
  rotatePts(points2, angle2);
  lines1 = makeLine(points1, 0);
  lines2 = makeLine(points2, angle2);
  for (Line l1 : lines1) {
    float minimum = dista;
    Line currl2 = null;
    for (Line l2 : lines2) {
      float curr = l1.distance(l2);
      if (curr < minimum) {
        minimum = curr;
        currl2 = l2;
      }
    }
    if (currl2 != null) {
      points.add(l1.intersect(currl2));
    }
  }
  for (Line l1 : lines2) {
    float minimum = 1;
    Line currl2 = null;
    for (Line l2 : lines1) {
      float curr = l1.distance(l2);
      if (curr < minimum) {
        minimum = curr;
        currl2 = l2;
      }
    }
    if (currl2 != null) {
      points.add(l1.intersect(currl2));
    }
  }
  last = millis()-500;
}

void mousePressed(){
  if (millis() - last < 300) {
    if (inState1) {
      cam.setState(state2,800);
      inState1 = false;
    } else {
      cam.reset(800);
      inState1 = true;
    }
  }
  last = millis();
}

List<PVector> parseFile(String fileName) {
  List<PVector> output = new ArrayList<PVector>();
  BufferedReader reader = createReader(fileName);
  String line = null;
  int counter = 0;
  try {
    while ((line = reader.readLine()) != null) {
      if (counter % density == 0) {
        String[] pieces = split(line, ", ");
        int x = int(pieces[0].substring(2));
        int y = int(pieces[1]);
        output.add(new PVector(x, y, 0));
      }
      counter++;
    }
    reader.close();
  } catch (IOException e) {
    e.printStackTrace();
  }
  return output;
}

void centerResize(List<PVector> pts, String word) {
  for (int i = 1; i < pts.size(); i++) {
    float intendedW = textWidth(word);
    float intendedH = textAscent() + textDescent();
    float factor = intendedW/pts.get(0).x;
    pts.get(i).mult(factor);
    pts.get(i).add(new PVector(-intendedW/2,intendedH/2-textDescent(),0));
  }
}

void rotatePts(List<PVector> pts, float angle) {
  List<PVector> justXZ = new ArrayList<PVector>();
  for (int i = 1; i < pts.size(); i++) {
    PVector p = pts.get(i);
    justXZ.add(new PVector(p.x, p.z));
    justXZ.get(i - 1).rotate(angle);
    p.x = justXZ.get(i - 1).x;
    p.z = justXZ.get(i - 1).y;
  }
}

List<Line> makeLine(List<PVector> pts, float angle) {
  PVector intermed = new PVector(0,away);
  intermed.rotate(angle);
  PVector source = new PVector(intermed.x, 0, intermed.y);
  List<Line> output = new ArrayList<Line>();
  for (int i = 1; i < pts.size(); i++) {
    output.add(new Line(pts.get(i), source));
  }
  return output;
}

void lerpPts(List<PVector> pts, float angle) {
  PVector intermed = new PVector(0,away);
  intermed.rotate(angle);
  PVector source = new PVector(intermed.x, 0, intermed.y);
  for (int i = 1; i < pts.size(); i++) {
    pts.get(i).lerp(source, (i-pts.size()*0.5)*0.001);
  }
}

void draw() {
  background(255);
  rotateY(angle);
  if (spinning) {
    angle -= 0.005;
  }
  for (int i = 1; i < points.size(); i++) {
    PVector p = points.get(i);
    point(p.x,p.y,p.z);
  }
}
