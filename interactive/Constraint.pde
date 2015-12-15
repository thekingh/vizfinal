public class Constraint extends Edge {
    
    float gravity;
    
    public Constraint() {
        this(new Node(), new Node(), 1);
    }

    public Constraint(Node n1, Node n2) {
        this(n1, n2, 3);
    }

    public Constraint(Node n1, Node n2, float gravity) {
        super(n1, n2);
        this.gravity = gravity;
    }

    public float getGravity() {
        return gravity;
    }

    public void setGravity(float newGravity) {
        this.gravity = newGravity; 
    }

    public void applySpringForces() {
        return;
    }

    public void applyBundleForces(Edge e, float c) {
        return;
    }

    public PVector getClosestPoint(PVector p) {
        PVector v = PVector.sub(p, left.pos);
        PVector u = PVector.sub(right.pos, left.pos);

        float r = PVector.dot(u, v);
        r = r/u.magSq();
        u.mult(r);

        PVector d = PVector.sub(u, v);

        PVector pt = PVector.add(p, d);
        
        if((pt.x >= left.pos.x)   && (pt.x <= right.pos.x) &&
           (pt.y <= bottom.pos.y) && (pt.y >= top.pos.y)) {
            return pt;
        } else {
            return null;
        }
    }
    
    public void render() {
        pushStyle();
        ellipse(n1.getPosition().x, n1.getPosition().y, 2, 2);
        ellipse(n2.getPosition().x, n2.getPosition().y, 2, 2);

        stroke(255, 0, 0, 100);
        line(n1.getPosition().x, n1.getPosition().y,
             n2.getPosition().x, n2.getPosition().y);

        popStyle();
    }
}
