import org.gicentre.geomap.*;
import java.util.TreeMap;

PImage orto;

City3D city;
float rotation = 0;

void setup() {

    //size(1200,800,P3D);
    size(1200,805,P3D);
    //pixelDensity(2);
    
    city = new City3D(this, "gis/buildings_simplified", width, height);
    city.paint(#37383a);
    
    city.update(width/2, height/2, 0, 3);
}


void draw() {
    
    background(#181B1C);

    city.draw();
 
    fill(0);
    text(frameRate, 20, 20);

}