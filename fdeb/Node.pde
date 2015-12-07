color NodeColor  = color(255, 0, 0);
float NodeRadius = 7.0;

public class Node {

    PVector pos;
    int id;

    public Node() {
        this(new PVector(0, 0), -1);
    }

    public Node(PVector p, int id) {
        this.id = id;
        this.pos = p;
    }

    public PVector getPosition() {
        return pos;
    }

    public int getID() {
        return id;
    }

    public void render() {
        
        pushStyle();
            
            fill(NodeColor);
            ellipse(pos.x, pos.y, NodeRadius*2, NodeRadius*2);

        popStyle();
    }

}
