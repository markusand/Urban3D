import java.util.TreeMap;
import java.util.Map.*;

public class ColorSchema {

    public final String TITLE;
    public final String UNIT;
    public final String ATTRIBUTE;
    
    private color invalid = #37383a;    // default invalid color
    private TreeMap<Float, Integer> colors;
    
    public ColorSchema(String title, String unit, String attr) {
        TITLE = title;
        UNIT = unit;
        ATTRIBUTE = attr;
        colors = new TreeMap();
    }
    
    
    public void setInvalid(color c) {
        invalid = c;
    }
    
    
    public void addColor(float value, color c) {
        colors.put(value, c);
    }
    
    
    public color getColor(float value) {
        if(value < colors.firstKey() || value > colors.lastKey()) return invalid;
        else {
            if(colors.containsKey(value)) return colors.get(value);
            else {
                float prev = colors.lowerKey(value);
                float next = colors.higherKey(value);
                float normValue = map(value, prev, next, 0, 1);
                return lerpColor(colors.get(prev), colors.get(next), normValue);
            }
        }
    }
    
    
    public void drawLegend(int x, int y, int w) {
        pushMatrix();
        pushStyle();
        translate(x, y);
        fill(#FFFFFF);
        textAlign(LEFT, BOTTOM); textSize(14);
        text(TITLE, 0, 12);
        textAlign(RIGHT, BOTTOM); textSize(12);
        text(UNIT, w, 12);
        
        beginShape(QUAD_STRIP);
        noStroke(); textSize(10);
        for(Entry<Float, Integer> c : colors.entrySet()) {
            float xPos = map(c.getKey(), colors.firstKey(), colors.lastKey(), 0, w);
            fill(c.getValue());
            vertex(xPos, 15);
            vertex(xPos, 25);
        }
        endShape();
        
        fill(#FFFFFF); textSize(9); textAlign(CENTER, TOP);
        for(Float v : colors.keySet()) {
            float xPos = map(v, colors.firstKey(), colors.lastKey(), 0, w);
            text(int(v), xPos, 28);
        }
        
        popStyle();
        popMatrix();
    }
    
    
}