public interface Pickable {
    public final int PICK_COLOR_BASE = 0xff000001;
    public int getPicker(int id);
}


public static abstract class LandArea {
    
    public static float px_m;
    
    protected final int ID;
    protected final TableRow ATTRIBUTES;
    protected final PVector[] CONTOUR;
    
    public LandArea(int id, TableRow attributes, PVector[] contour) {
        ID = id;
        ATTRIBUTES = attributes;
        CONTOUR = contour;
    }

    public PVector getCentroid() {
        PVector centroid = new PVector();
        for(PVector vertex : CONTOUR) {
            centroid.add(vertex);
        }
        centroid.div(CONTOUR.length);
        return centroid;
    }

}

public class Building3D extends LandArea implements Pickable {

    protected final int PICK_COLOR;
    protected PShape extrusion;
    private color fillColor;
    
    public Building3D(int id, TableRow attributes, PVector[] contour) {
        super(id, attributes, contour);
        extrude(ATTRIBUTES.getInt("elevation") * px_m, ATTRIBUTES.getInt("height") * px_m );
        PICK_COLOR = getPicker(id);
    }


    public int getPicker(int id) {
        return PICK_COLOR_BASE + 2 * id;
    }
    

    public void extrude(float base, float h) {
        extrusion = createShape(GROUP);
        
        // Build sides
        for(int i = 1; i < CONTOUR.length; i++) {
            PShape side = createShape();
            side.beginShape();
            side.vertex(CONTOUR[i-1].x, CONTOUR[i-1].y, base);
            side.vertex(CONTOUR[i-1].x, CONTOUR[i-1].y, base + h);
            side.vertex(CONTOUR[i].x, CONTOUR[i].y, base + h);
            side.vertex(CONTOUR[i].x, CONTOUR[i].y, base);
            side.endShape(CLOSE);
            extrusion.addChild(side);
        }
        
        // Build closing side
        int last = CONTOUR.length-1;
        PShape side = createShape();
        side.beginShape();
        side.vertex(CONTOUR[0].x, CONTOUR[0].y, base);
        side.vertex(CONTOUR[0].x, CONTOUR[0].y, base + h);
        side.vertex(CONTOUR[last].x, CONTOUR[last].y, base + h);
        side.vertex(CONTOUR[last].x, CONTOUR[last].y, base);
        side.endShape(CLOSE);
        extrusion.addChild(side);
        
        // Build cover & centroid
        PShape cover = createShape();
        cover.beginShape();
        for(int i = 0; i <= last; i++) {
            cover.vertex(CONTOUR[i].x, CONTOUR[i].y, base + h);
        }
        cover.endShape(CLOSE);
        extrusion.addChild(cover);
        
        // Default building color
        setColor(#FAFAFA);
        strokeWeight(1);
    }
    
    
    public void draw() {
        shape(extrusion);
    }
    
    
    public void draw(PGraphics canvas) {
        canvas.shape(extrusion);
    }
    
    
    public void drawForPicking(PGraphics canvas) {
        extrusion.setFill(PICK_COLOR);
        extrusion.setStroke(PICK_COLOR);
        draw(canvas);
        paint();
    }
    
    
    public void setColor(color c) {
        fillColor = c;
        paint();
    }
    
    
    public void paint() {
        paint(fillColor);
    }
    
    
    public void paint(color c) {
        extrusion.setFill(c);
        color strokeColor = brightness(c) > 125 ?
              color(red(c)-5, green(c)-5, blue(c)-5) :
              color(red(c)+10, green(c)+10, blue(c)+10);
        extrusion.setStroke(strokeColor);
    }
    
    
    public void strokeWeight(float weight) {
        if(weight == 0) extrusion.setStroke(false);
        else extrusion.setStrokeWeight(weight);
    }
    
}