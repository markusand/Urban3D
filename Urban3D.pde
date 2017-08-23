import org.gicentre.geomap.*;
import java.util.TreeMap;


City3D city;

public enum Projection { EPSG4326, EPSG3857 };

void setup() {

    //size(1200,800,P3D);
    size(1200,805,P3D);
    //pixelDensity(2);
    
    city = new City3D(this, width, height, "gis/buildings_EPSG3857", Projection.EPSG3857);
    //city.paint(#37383a);
    TreeMap<Float, Integer> floorColor = new TreeMap();
    floorColor.put(10f, #00FF00);
    floorColor.put(100f, #f0cb35);
    floorColor.put(313f, #C02425);
    city.lerpPaint("elev",floorColor);
    
    city.update(width/2, height/2, 0, 3);
}


void draw() {
    
    background(#181B1C);

    city.draw();
 
    fill(#FFFFFF);
    text(frameRate, 20, 20);

}

void mouseDragged() {
    float dX = pmouseX - mouseX;
    city.rotate(map(dX, 0, width, 0, TWO_PI));
}

void mouseClicked() {
    int i = city.pick(mouseX, mouseY);
    city.highlight(i, #00FF00);    // #E40205
    city.centerAt(i);
}

void keyPressed() {
    switch(key) {
        case '+':
            city.zoom(1);
            break;
        case '-':
            city.zoom(-1);
            break;
        case CODED:
            switch(keyCode) {
                case LEFT:
                    city.move(-10, 0);
                    break;
                case RIGHT:
                    city.move(10, 0);
                    break;
                case UP:
                    city.move(0, -10);
                    break;
                case DOWN:
                    city.move(0, 10);
                    break;
            }
            break;
    }
}