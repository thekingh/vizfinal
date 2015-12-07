public class ControlPoint {

    PVector pos, v, a;

    public ControlPoint() {
        this(new PVector(0, 0));
    }

    public ControlPoint(PVector pos) {
        this.pos = pos;
        v = new PVector(0, 0);
        a = new PVector(0, 0);
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
}
