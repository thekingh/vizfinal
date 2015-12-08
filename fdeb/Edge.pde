final int NUM_SUBS = 32;

public class Edge {

    Node n1, n2; // make ints for optimization?
    ControlPoint[] cps;
    float len;

    Node left, right;

    public Edge() {
        this(new Node(), new Node());
    }

    public Edge(Node n1, Node n2) {

        this.n1 = n1;
        this.n2 = n2;

        left  = (n1.getPosition().x  < n2.getPosition().x) ? n1 : n2;
        right = (n1.getPosition().x >= n2.getPosition().x) ? n1 : n2;
        len = PVector.dist(n1.getPosition(),n2.getPosition());

        cps = new ControlPoint[NUM_SUBS];
        initControlPoints();

    }

/*
    private float scaleCompatibility(e)
    {    
    }

    public float get EdgeVector(boolean )
    {
    }
    */
    
    // Returns true if e is the same edge
    public boolean equals(Edge e) {
        return left.id == e.left.id && right.id == e.right.id;
    }

    // Returns true if this edge has an angle > 45
    public boolean isVertical() {
        float angle = PVector.sub(left.pos,right.pos).heading();
        return (angle > PI*.25 && angle < PI * .75) ||
               (angle > PI*1.25 && angle < PI * 1.75);
    }

    public float getMagnitude() {
        float magnitude = 0;
        for (ControlPoint cp : cps) {
            magnitude += cp.getVelocity().mag();
        }

        return magnitude;
    }

    // always populate left to right
    private void initControlPoints() {
        
        if(right == null || left == null) {
            //println("FUCK");
        }
        
        PVector dir = PVector.sub(right.getPosition(), left.getPosition()); //watch out if n1 posn == n2 posn
        dir.normalize();
        float segmentLength = len / (NUM_SUBS+1);
        //println("SL: " + segmentLength);
        for (int i = 0; i < NUM_SUBS; i++) {
            cps[i] = new ControlPoint(PVector.add(left.getPosition(),
                                      PVector.mult(dir, segmentLength * (i+1))));
            //println("cpx: " + cps[i].getPosition().x);
        }
    }

    public void zeroForces() {
       for (ControlPoint cp : cps) {
            cp.zeroForce();
       }
    }

    // Call this once per edge update cycle
    public void applySpringForces() {
        float localSF = SPRING_CONST / (NUM_SUBS+1);
        PVector leftPos, rightPos;
        for (int i = 0; i < NUM_SUBS; i++) {
            if (i == 0) {
                // Apply force from left
                leftPos = left.getPosition();
                rightPos = cps[i+1].getPosition();
            } else if (i == NUM_SUBS - 1) {
                // Apply force from right
                leftPos = right.getPosition();
                rightPos = cps[i-1].getPosition();
            } else {
                // Apply forces between cps
                rightPos = cps[i+1].getPosition();
                leftPos = cps[i-1].getPosition();
            }
            cps[i].applySpringForce(rightPos, len);
            cps[i].applySpringForce(leftPos, len);
        }
    }

    // PERHAPS A BETTER Q TO ASK IS WHICH IS CLOSER: left endpoints or top or endpoints...
    // Apply forces from incoming edge to this edge
    public void applyBundleForces(Edge e) {
       // Check if we need to do a vertical scan of control points 
       boolean vertical = isVertical() || e.isVertical();
       boolean divergent = (left.pos.y < right.pos.y && 
                           e.left.pos.y > e.right.pos.y) ||
                          (left.pos.y > right.pos.y &&
                           e.left.pos.y < e.right.pos.y);

       
       // boolean vertical = false;
       for (int i = 0; i < NUM_SUBS; i++) {
           int index = vertical && divergent ? NUM_SUBS-1-i : i;
           //cps[i].applyBundleForce(e.cps[i]);        
           cps[index].applyBundleForce(e.cps[i]);        
       }
    }

    public void update(float t) {
       for (ControlPoint cp : cps) {
            cp.update(t);
       }
    }

    public void render() {

        // Draws a ghost of pre-bundled edge
        if (SHOW_ORIGINAL) {
            pushStyle();
            fill(0,.02);
            float pixel_spacing = 12;
            float n_pts = PVector.dist(left.pos, right.pos) / pixel_spacing;
            for (int i = 0; i < n_pts; i++) {
                PVector pt = PVector.lerp(left.pos, right.pos, i/n_pts);
                ellipse(pt.x, pt.y, 1, 1);
            }
            popStyle();
        }

        pushStyle();
        for(int i = 0; i <= NUM_SUBS; i++) {
            color c = color(i*8, 0,0);    
            stroke(c);
            if(i == 0) {
                vline(left.getPosition(), cps[i].getPosition());
            } else if (i == NUM_SUBS) {
                vline(cps[i-1].getPosition(), right.getPosition());
            } else {
                vline(cps[i-1].getPosition(), cps[i].getPosition());
            }
            if (i < NUM_SUBS) {
               //cps[i].render(2);
            }

        }

        popStyle();
    }

}
