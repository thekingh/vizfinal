int radius = 30;

public class Node {

    int id;
    int mass;
    color c;

    PVector pos;
    PVector velocity;
    PVector force;

    Node() {
        id   = -1;
        mass = -1;

        pos      = new PVector(0, 0);
        velocity = new PVector(0, 0);
        force    = new PVector(0, 0);

        c = white;
    }

    Node(int _id, int _mass) {
        id   = _id;
        mass = _mass;
        pos      = new PVector(0, 0);
        velocity = new PVector(0, 0);
        force    = new PVector(0, 0);
        c = white;
    }

    public int getID() {
        return id;
    }

    public int getMass() {
        return mass;
    }

    public PVector getPosition() {
        return pos;
    }

    public void setPosition(PVector _position) {
        pos = _position;
    }

    public void setID(int _id) {
        id = _id;
    }

    public void setMass(int _mass) {
        mass = _mass;
    }

    public PVector getVelocity() {
        return velocity;
    }

    public void setVelocity(PVector _v) {
        velocity = _v;
    }

    public PVector getForce() {
        return force;
    }

    public void setForce(PVector _v) {
        force = _v;
    }

    public void setColor(color _c) {
        c = _c;
    }

    public color getColor() {
        return c;
    }

    private void setForceColor() {

        if(isHovering()) {
            if(cur_node != null && cur_node.getID() == id) {
                c = darkBlue;
                colorMode(HSB);
                color sc = color(4, 500 * sqrt(force.mag()/maxForce), 300);
                stroke(sc);
                strokeWeight(5);
                colorMode(RGB);
            } else {
                c = lightBlue;
            }
        } else {
            colorMode(HSB);
            c = color(4, 500 * sqrt(force.mag()/maxForce), 300);
            colorMode(RGB);
        }
    }


    public boolean isHovering() {
        if((mouseX < pos.x + radius/2) && (mouseY < pos.y + radius/2) &&
           (mouseX > pos.x - radius/2) && (mouseY > pos.y - radius/2)) {
           return true;
        }

        return false;
    }

    public void render() {
        setForceColor(); 
        fill(c);
        ellipse(pos.x, pos.y, radius, radius);

        strokeWeight(1);
        stroke(black);
        fill(black);
        String tmp = "" + id;
        text(tmp, pos.x, pos.y, pos.x, pos.y);
        fill(white);
    }
}
