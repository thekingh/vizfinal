public class ControlPoint {
    
    PVector pos, v, a, f;

    public ControlPoint() {
        this(new PVector(0, 0));
    }

    public ControlPoint(PVector pos) {
        this.pos = pos;
        v = new PVector(0, 0);
        a = new PVector(0, 0);
        f = new PVector(0, 0);
    }

    public PVector getPosition() {
        return pos;
    }

    public PVector getVelocity() {
        return v;
    }

    public PVector getAcceleration() {
        return a;
    }

    public PVector getForce() {
        return f;
    }

    public void zeroForce() {
        f.mult(0);
    }

    // posn = position of connected node
    // Note: springs between control points are zero-length springs
    public void applySpringForce(PVector toPos, float len) {
        
        // normalized vector from this cp to toPos
        PVector force = PVector.sub(toPos, pos);
        force.normalize();

        float dist = PVector.dist(pos, toPos);
        
        // Update force
        f.add(PVector.mult(force, dist * SPRING_CONST / ( (len * NUM_SUBS))));
    }

    // applies attraction force from given control point onto this control point
    public void applyBundleForce(ControlPoint cp, float coeff) {
        PVector force = PVector.sub(cp.getPosition(), pos);
        force.normalize();
        
        float r = PVector.dist(pos, cp.pos);
        if (r < 1) return;
        force.mult(BUNDLE_CONST/(r*r));
        // force.mult(BUNDLE_CONST / r);
        force.mult(coeff);
        f.add(force);
    }

    public void update(float t) {
        PVector dampF = new PVector(v.x, v.y);
        dampF = PVector.mult(v,-0.2);
        f.add(dampF);

        a = f;
        pos = PVector.add(pos, PVector.add((PVector.mult(v, t)),
                               PVector.mult(a, 0.5*t*t)));
        v = PVector.add(v, PVector.mult(a,t));

    }

    public void render(float radius) {
        pushStyle();
        fill(0,0,255);
        ellipse(pos.x, pos.y, radius * 2, radius * 2);
        popStyle();
    }
}
