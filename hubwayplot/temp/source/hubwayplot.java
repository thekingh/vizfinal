import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class hubwayplot extends PApplet {



PGraphics hubmap;
HashMap<Integer, PVector> stations;
String data_folder = "../data/";
PVector latrange;
PVector lonrange;

public void setup()
{
    size(800, 600);
    stations = new HashMap<Integer, PVector>(145);

    buildStations(data_folder + "hubway_stations.csv");
    hubmap = generateMap(data_folder + "hubway_trips.csv");
}

public void buildStations(String file)
{
    String lines[] = loadStrings(file);
    for (int i = 1; i < lines.length; i++) {
        String line[] = split(lines[i], ",");
        Integer id = Integer.parseInt(line[0]);
        float lat = Float.parseFloat(line[4]);
        float lon = Float.parseFloat(line[5]);
        
        if (i == 1) {
            latrange = new PVector(lat, lat);
            lonrange = new PVector(lon, lon);
        } else {
            if (lat < latrange.x) latrange.x = lat;
            if (lat > latrange.y) latrange.y = lat;
            if (lon < lonrange.x) lonrange.x = lon;
            if (lon > lonrange.y) lonrange.y = lon;
        }
        
        stations.put(id, new PVector(lat, lon));
    }
}

public PGraphics generateMap(String file) {
    PGraphics hubmap = createGraphics(width, height);
    float latr = latrange.y - latrange.x;
    float lonr = lonrange.y - lonrange.x;
    String lines[] = loadStrings(file);
    hubmap.beginDraw();
    hubmap.background(255);
    hubmap.fill(0,0,0,.05f);
    //int cutoff = (int) (lines.length * .01);
    int cutoff = 30;
    int plotted = 0;
    hubmap.stroke(0);
    for (int i = 1; plotted < cutoff && i < lines.length; i++) {
        String line[] = split(lines[i], ",");
        try
        {
            Integer start_id = Integer.parseInt(line[5]);
            Integer end_id   = Integer.parseInt(line[7]);
            if (start_id == end_id) continue;
            PVector spos = stations.get(start_id);
            PVector epos = stations.get(end_id);
            hubmap.line(lerp(50,width - 50 , (spos.x - latrange.x)/ latr),  
                        lerp(50,height- 50 , (spos.y - lonrange.x)/ lonr),
                        lerp(50,width - 50 , (epos.x - latrange.x)/ latr), 
                        lerp(50,height- 50 , (epos.y - lonrange.x)/ lonr));
        } catch (NumberFormatException e) {
            continue;
        }
        plotted++;
    }
    hubmap.fill(255,.5f);
    hubmap.stroke(0);
    for (PVector stationpos : stations.values()) {
        hubmap.ellipse(scaleX(stationpos.x), scaleY(stationpos.y), 3, 3);
    }
    hubmap.endDraw();
    return hubmap;
}

public float scaleY (float v)
{
    return lerp(50, height - 50, (v - lonrange.x) / (lonrange.y - lonrange.x));
}

public float scaleX (float v)
{
    return lerp(50, width - 50, (v - latrange.x) / (latrange.y - latrange.x));
}

public void draw()
{
    clear();
    background(255);
    image(hubmap, 0, 0, width, height);
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "hubwayplot" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
