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
            noStroke();
            fill(NODE_COLOR);
            ellipse(pos.x, pos.y, NODE_RADIUS*2, NODE_RADIUS*2);
        popStyle();
    }

}
