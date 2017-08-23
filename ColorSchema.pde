import java.util.TreeMap;

public class ColorSchema {

    public final String TITLE;
    public final String UNIT;
    public final String ATTRIBUTE;
    
    private color invalid = #F0F0F0;    // default invalid color
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
    
    
}