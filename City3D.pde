import java.util.TreeMap;

public class City3D {
    
    private final PApplet PARENT;
    private final int WIDTH, HEIGHT;
    
    private ArrayList<Building3D> buildings;
    
    private boolean interactive = true;
    private PVector screenPos;
    private PVector centerTarget;
    private PVector centerPoint;
    private float rotationTarget = 0;
    private float rotation = 0;
    private float scaleTarget = 1;
    private float scale = 1;
    
    private PGraphics canvas;
    
    public City3D(PApplet parent, int width, int height) {
        PARENT = parent;
        WIDTH = width;
        HEIGHT = height;
        
        screenPos = new PVector(parent.width/2, parent.height/2);
        centerPoint = new PVector(WIDTH/2, HEIGHT/2);
        centerTarget = new PVector(WIDTH/2, HEIGHT/2);
        canvas = createGraphics(parent.width, parent.height, P3D);
        
        parent.registerMethod("mouseEvent", this);
        parent.registerMethod("keyEvent", this);
    }
    
    public City3D(PApplet parent, int width, int height, String pathGIS, Projection proj) {
        this(parent, width, height);
        load(pathGIS, proj);
    }
    
    
    public void load(String pathGIS, Projection proj) {
        
        GeoMap geoMap = new GeoMap(0, 0, WIDTH, HEIGHT, PARENT);
        geoMap.readFile(pathGIS);
        Table attributes = geoMap.getAttributeTable();
        
        float dY = geoMap.getMaxGeoY() - geoMap.getMinGeoY();
        if(proj == Projection.EPSG4326) dY *= 111320;
        LandArea.px_m = HEIGHT / dY;
        
        buildings = new ArrayList();
        for(int i = 0; i < geoMap.getNumPolys(); i++) {
            
            Polygon poly = (Polygon)geoMap.getFeatures().get(i+1);    // GeoMap starts indexing at 1
            PVector[] contour = new PVector[poly.getNumVertices()-1];
            float[] x = poly.getXCoords();
            float[] y = poly.getYCoords();
            for(int v = 0; v < poly.getNumVertices()-1; v++) {
                contour[v] = geoMap.geoToScreen(x[v], y[v]);  
            }
            Building3D building = new Building3D(i, attributes.getRow(i), contour);

            buildings.add(building);
        }
        
        update();
    }
    
    
    public void draw() {
       
        boolean update = false;
        if(centerPoint.dist(centerTarget) > 1) {
            centerPoint.lerp(centerTarget, 0.5);
            update = true;
        }
        if(abs(rotationTarget - rotation) > 0.00873) {
            rotation = lerp(rotation, rotationTarget, 0.5);
            update = true;
        }
        if(abs(scaleTarget - scale) > 0.1) {
            scale = lerp(scale, scaleTarget, 0.5);
            update = true;
        }
        if(update) update();
        
        image(canvas, 0, 0);    
    }
    
    
    public void update(int centerX, int centerY, float rot, float sc) {
        screenPos = new PVector(centerX, centerY);
        rotationTarget = radians(rot);
        scaleTarget = sc;
    }
    
    
    public void update() {
        canvas.beginDraw();
        canvas.clear();
        canvas.lights();
        canvas.pushMatrix();
        canvas.translate(screenPos.x, screenPos.y,0);
        canvas.rotateX(QUARTER_PI);
        canvas.rotateZ(rotation);
        canvas.scale(scale);
        canvas.translate(-centerPoint.x, -centerPoint.y, 0);
        for(Building3D building : buildings) {
            building.draw(canvas);
        }
        canvas.popMatrix();
        canvas.endDraw();
    }
    
    
    public void setInteractivity(boolean i) {
        interactive = i;
    }

    
    public void rotate(float rotation) {
        rotationTarget += rotation;
    }
    
    
    public void move(float dX, float dY) {
        PVector mov = new PVector(dX, dY).rotate(-rotation);
        centerTarget.add(mov);
    }
    
    
    public void zoom(float dScale) {
        if(scaleTarget + dScale > 0) scaleTarget += dScale;
        else scaleTarget = 1;
    }
    
    
    public void paint(color c) {
        for(Building3D building : buildings) {
            building.setColor(c);
        }
    }
    
    
    public void paint(String column, IntDict colors) {
        for(Building3D building : buildings) {
            if(colors.hasKey(building.ATTRIBUTES.getString(column))) {
                building.setColor(colors.get( building.ATTRIBUTES.getString(column)));
            }
        }
    }
    
    
    public void paint(ColorSchema sch) {
        for(Building3D building : buildings) {
            float value = building.ATTRIBUTES.getFloat(sch.ATTRIBUTE);
            building.setColor( sch.getColor(value) );
        }
    }
    
    
    public void highlight(int i, color fillColor) {
        for(Building3D building : buildings) {
            if(building.ID == i) building.paint(fillColor);
            else building.paint();      
        }
    }
    
    
    public void centerAt(int i) {
        if(i == -1) centerTarget = new PVector(WIDTH/2, HEIGHT/2);
        else {
            for(Building3D building : buildings) {
                if(building.ID == i) {
                    centerTarget = building.getCentroid();
                    break;
                }
            }
        }
        update();
    }
    
    
    public int pick(int x, int y) {
        PGraphics pickMap = createGraphics(width, height, P3D);
        pickMap.beginDraw();
        pickMap.background(0);
        pickMap.pushMatrix();
        pickMap.translate(screenPos.x, screenPos.y,0);
        pickMap.rotateX(QUARTER_PI);
        pickMap.rotateZ(rotation);
        pickMap.scale(scale);
        pickMap.translate(-centerPoint.x, -centerPoint.y, 0);
        for(Building3D building : buildings) {
            if(building instanceof Pickable) building.drawForPicking(pickMap);
        }
        pickMap.popMatrix();
        pickMap.endDraw();
        int c = pickMap.get(x * sketchPixelDensity(), y * sketchPixelDensity());
        for(Building3D building : buildings) {
            if(building instanceof Pickable && c  == building.PICK_COLOR) return building.ID;
        }
        return -1;
    }
    
    
    public void mouseEvent(MouseEvent e) {
        if(!interactive) return;
        switch(e.getAction()) {
            case MouseEvent.DRAG:
                float dX = pmouseX - mouseX;
                city.rotate(map(dX, 0, width, 0, TWO_PI));
                break;
        }
    }
    
    
    public void keyEvent(KeyEvent e) {
        if(!interactive) return;
        if(e.getAction() == KeyEvent.PRESS) {
            switch(e.getKey()) {
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
    }
    
}