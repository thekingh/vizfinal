public class Constraint extends Edge {
    
    float gravity;
    
    public Constraint() {
        this(new Node(), new Node(), 1);
    }

    public Constraint(Node n1, Node n2) {
        this(n1, n2, 1);
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

    public void render() {
        
        ellipse(n1.getPosition().x, n1.getPosition().y, 2, 2);
        ellipse(n2.getPosition().x, n2.getPosition().y, 2, 2);

        stroke(255, 0, 0);
        line(n1.getPosition().x, n1.getPosition().y,
             n2.getPosition().x, n2.getPosition().y);

    }
}
