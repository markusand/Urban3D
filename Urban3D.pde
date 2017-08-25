import org.gicentre.geomap.*;

City3D city;

ArrayList<ColorSchema> colors = new ArrayList();
int it = -1;

public enum Projection { EPSG4326, EPSG3857 };

void setup() {

    size(1200,805,P3D);
    
    // CAUTION! Bug: Picker not working with pixelDensity(2).
    // Keep commented until fixed
    //pixelDensity(2); 
    
    city = new City3D(this, width, height, "gis/buildings", Projection.EPSG3857);
    city.paint(#37383a);
    
    ColorSchema ir = new ColorSchema("Irradiació Útil", "kWh/m2", "ir_use");
    ir.addColor(0.1, #636bff);
    ir.addColor(396, #70ff67);
    ir.addColor(792, #fcf663);
    ir.addColor(1189, #e24f4f);
    colors.add(ir);
    
    ColorSchema pot = new ColorSchema("Potència Instal·lable", "W", "pow_instal");
    pot.addColor(0.1, #fcf663);
    pot.addColor(336, #e24f4f);
    pot.addColor(672, #ff91f7);
    colors.add(pot);
    
    ColorSchema elec = new ColorSchema("Electricitat Generada", "MWh", "electr_gen");
    elec.addColor(0.1, #fcf663);
    elec.addColor(672, #e24f4f);
    colors.add(elec);
    
    ColorSchema co2 = new ColorSchema("Estalvi CO2", "t CO2", "co2_saving");
    co2.addColor(0.1, #d2e68d);
    co2.addColor(2195, #297d7d);
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
    if(it != -1) colors.get(it).drawLegend(40,40, 200);
    //text(frameRate, 20, 20);

}


void mouseClicked() {
    int i = city.pick(mouseX, mouseY);
    city.highlight(i, #00FF00);    // #E40205
    city.centerAt(i);
}

void keyPressed() {
    switch(key) {
        case 'r':
            it = -1;
            city.paint(#37383a);
            city.update();
            break;
            
        case ' ':
            it = (it + 1) % colors.size();
            city.paint( colors.get(it) );
            city.update();
            break;
    }
}