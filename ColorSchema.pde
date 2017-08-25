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
        float min = colors.firstKey();
        float max = colors.lastKey();
        pushMatrix();
        pushStyle();
        translate(x, y);
        fill(0, 170); noStroke();
        rect(0, 0, w, 65, 5);
        fill(#FFFFFF);
        textAlign(LEFT, BOTTOM); textSize(16);
        text(TITLE, 15, 27);
        textAlign(RIGHT, BOTTOM); textSize(14);
        text(UNIT, w - 15, 27);
        beginShape(QUAD_STRIP);
        for(Entry<Float, Integer> c : colors.entrySet()) {
            float xPos = map(c.getKey(), min, max, 15, w - 15);
            fill(c.getValue());
            vertex(xPos, 30);
            vertex(xPos, 40);
        }
        endShape();
        fill(#FFFFFF); textSize(11);
        for(Float v : colors.keySet()) {
            float xPos = map(v, min, max, 15, w-15);
            if(v.equals(min)) textAlign(LEFT, TOP);
            else if(v.equals(max)) textAlign(RIGHT, TOP);
            else textAlign(CENTER, TOP);
            text(int(v), xPos, 43);
        }
        popStyle();
        popMatrix();
    }
    
    
}