import org.gicentre.geomap.*;

City3D city;

ArrayList<ColorSchema> colors = new ArrayList();
int it;

public enum Projection { EPSG4326, EPSG3857 };

void setup() {

    size(1200,805,P3D);
    pixelDensity(2);
    
    city = new City3D(this, width, height, "gis/buildings", Projection.EPSG3857);
    city.paint(#37383a);
    
    ColorSchema sup = new ColorSchema("SUPERFÍCIE ÚTIL", "m2", "surf_use");
    sup.addColor(0.1, #F0F0F0);
    sup.addColor(4564, #FF0000);
    colors.add(sup);
    
    ColorSchema ir = new ColorSchema("IRRADIACIÓ ÚTIL", "kWh/m2", "ir_use");
    ir.addColor(500, #fff89e);
    ir.addColor(1189, #FF6961);
    colors.add(ir);
    
    ColorSchema pot = new ColorSchema("POTENCIA INSTAL·LABLE", "W", "pow_instal");
    pot.addColor(0.1f, #FFFF00);
    pot.addColor(672f, #FF0000);
    colors.add(pot);
    
    ColorSchema elec = new ColorSchema("ELECTRICITAT GENERADA", "MWh", "electr_gen");
    elec.addColor(0.1f, #FFFF00);
    elec.addColor(672f, #FF0000);
    colors.add(elec);
    
    ColorSchema co2 = new ColorSchema("ESTALVI CO2", "t CO2", "co2_saving");
    co2.addColor(0.1, #d2e68d);
    co2.addColor(2195f, #297d7d);
    colors.add(co2);
    
    /*
    IntDict useColor = new IntDict();
    useColor.add("Residential", #8E9E82);
    useColor.add("Sport",#8FB58C);
    useColor.add("Office", #A9C1D9);
    useColor.add("Commercial", #607890);
    useColor.add("Hostelry", #B8E6FF);
    city.paint("Use", useColor);
    */
    
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
        
        case ' ':
            it = (it + 1) % colors.size();
            city.paint( colors.get(it) );
            city.update();
            break;
    }
}