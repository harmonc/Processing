import java.util.regex.*;
import processing.svg.*;

//Name of .osm file that is being turned into a svg and the file that is being created.
final String MAP = "tall test";
final String saveLocation = "save/test.svg";

float minlat, maxlat, minlon, maxlon, w, h;
final color BACKGROUND = color(255);
final color FOREGROUND = color(206, 216, 247);

void setup() {
  HashMap<String, PVector> points = new HashMap();
  strokeWeight(1);
  //stroke(FOREGROUND);
  background(BACKGROUND);
  size(800, 800, SVG, saveLocation);
  String[] map = loadStrings(MAP+".osm");
  noFill();
  float r = 0;
  PVector mid =  new PVector(0, 0);

  ArrayList<PVector> shape = new ArrayList();
  boolean water = false;

  for (String line : map) {
    if (Pattern.matches(".*bounds.*", line)) {
      minlat = floatTag("minlat", line);
      maxlat = floatTag("maxlat", line);
      minlon = floatTag("minlon", line);
      maxlon = floatTag("maxlon", line);
      w = maxlon - minlon;
      h = maxlat - minlat;
      println("minlat:"+minlat+", maxlat:"+maxlat+
        ", minlon:"+minlon+", maxlon:"+maxlon);
      println("latH:"+(maxlat-minlat));
      println("lonW:"+(maxlon-minlon));
      r = width/2.0;
      mid = new PVector(minlon + (maxlon-minlon)/2.0, minlat + (maxlat-minlat)/2.0);
      mid = new PVector(map(mid.x, minlon, maxlon, 0, width), map(mid.y, minlat, maxlat, height, 0));
      println(r);
      println(mid.x + "," + mid.y);
    } else if (Pattern.matches(".*lat=.*lon=.*", line)) {
      float lat = floatTag("lat", line);
      float lon = floatTag("lon", line);
      String id = stringTag("id", line);
      PVector p = new PVector(map(lon, minlon, maxlon, 0, width*(w/h)), map(lat, minlat, maxlat, height, 0));
      points.put(id, p);
    } else if (Pattern.matches(".*<way.*", line)) {
      shape.clear();
      water = false;
      if (stringTag("id", line).equals("753194101")) {
        water = true;
      }
    } else if (Pattern.matches(".*<nd.*", line)) {
      String id = stringTag("ref", line);
      PVector p = points.get(id);
      if (p.x < width && p.x > 0 && p.y < height && p.y>0) {
        shape.add(p);
      }
      //println("p:"+p.x+","+p.y);
      //println("mid:"+mid.x+","+mid.y);
      //println(dist(mid.x,mid.y,p.x,p.y));


      //vertex(p.x,p.y);
    } else if (Pattern.matches(".*</way>.*", line)) {
      if (water) {
      //  fill(0, 0, 255);
      } else {
        noFill();
      }
      beginShape(); 
      for (PVector p : shape) {
        ////stroke(206, 216, 247, map(dist(mid.x, mid.y, p.x, p.y), 0, r, 255, 0));
        //stroke(0,map(dist(mid.x,mid.y,p.x,p.y),0,r,255,0));
        vertex(p.x, p.y);
      }
      endShape();
    } else if (Pattern.matches(".*<tag.*", line) && stringTag("v", line).equals("water")) {
      //water = true;
    } else if (Pattern.matches(".*<tag.*", line) && stringTag("v", line).equals("riverbank")) {
      //water = true;
    }
  }
  //endShape();
  //saveFrame(MAP+".png");
  exit();
}

float floatTag(String tag, String line) {
  Pattern p = Pattern.compile(".*"+tag+"=\"([^\"]*)\".*");
  Matcher m = p.matcher(line);
  m.matches();
  String capture = m.group(1);
  float result = Float.parseFloat(capture);
  return result;
}

String stringTag(String tag, String line) {
  Pattern p = Pattern.compile(".*\\s"+tag+"=\"([^\"]*)\".*");
  Matcher m = p.matcher(line);
  m.matches();
  String capture = m.group(1);
  return capture;
}
