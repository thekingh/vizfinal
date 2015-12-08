final int NUM_SUBS = 32;

public class Edge {

    Node n1, n2; // make ints for optimization?
    ControlPoint[] cps;
    boolean isCPSTopDown;
    float len;

    Node left, right;
    Node top, bottom; 

    public Edge() {
        this(new Node(), new Node());
    }

    public Edge(Node n1, Node n2) {

        this.n1 = n1;
        this.n2 = n2;

        left  = (n1.getPosition().x  < n2.getPosition().x) ? n1 : n2;
        right = (n1.getPosition().x >= n2.getPosition().x) ? n1 : n2;

        top  = (n1.getPosition().y  < n2.getPosition().y) ? n1 : n2;
        bottom = (n1.getPosition().y >= n2.getPosition().y) ? n1 : n2;

        len = PVector.dist(n1.getPosition(),n2.getPosition());

        cps = new ControlPoint[NUM_SUBS];
        initControlPoints();
        isCPSTopDown = left.getPosition().y < right.getPosition().y;
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

    //returns the order in which CPs should be matched
    public CPOrder calcCPOrder(Edge e)
    {
        float leftDist = PVector.dist(left.getPosition(), 
                                      e.left.getPosition());
        float rightDist = PVector.dist(right.getPosition(),
                                       e.right.getPosition());
        float topDist = PVector.dist(top.getPosition(),
                                     e.top.getPosition());
        float bottomDist = PVector.dist(bottom.getPosition(),
                                        e.bottom.getPosition());
        CPOrder cpOrder = CPOrder.LEFT_RIGHT;
        if (leftDist <= leftDist && leftDist <= rightDist && 
            leftDist <= topDist && leftDist <= bottomDist)
            cpOrder = CPOrder.LEFT_RIGHT;
        else if (rightDist <= leftDist && rightDist <= rightDist && 
                 rightDist <= topDist && rightDist <= bottomDist)
            cpOrder = CPOrder.RIGHT_LEFT;
        else if (topDist <= leftDist && topDist <= rightDist && 
                 topDist <= topDist && topDist <= bottomDist)
            cpOrder = CPOrder.TOP_DOWN;
        else if (bottomDist <= leftDist && bottomDist <= rightDist && 
                 bottomDist <= topDist && bottomDist <= bottomDist) 
            cpOrder = CPOrder.BOTTOM_UP;
        return cpOrder;
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
        PVector dir = PVector.sub(right.getPosition(), left.getPosition()); //watch out if n1 posn == n2 posn
        dir.normalize();
        float segmentLength = len / (NUM_SUBS+1);
        for (int i = 0; i < NUM_SUBS; i++) {
            cps[i] = new ControlPoint(PVector.add(left.getPosition(),
                                      PVector.mult(dir, segmentLength * (i+1))));
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

    // Apply forces from incoming edge to this edge
    public void applyBundleForces(Edge e) {
        CPOrder cpOrder = calcCPOrder(e);
        for (int i = 0; i < NUM_SUBS; i++) {
            int index = i;
            if (cpOrder == CPOrder.TOP_DOWN || cpOrder == CPOrder.BOTTOM_UP) { 
                index = isCPSTopDown == e.isCPSTopDown ? i : NUM_SUBS-1-i;
            }
            cps[index].applyBundleForce(e.cps[i]);        
        }
    }

    public void drawBundeForce(Edge e)
    {
        CPOrder cpOrder = calcCPOrder(e);
        for (int i = 0; i < NUM_SUBS; i++) {
            int index = i;
            if (cpOrder == CPOrder.TOP_DOWN || cpOrder == CPOrder.BOTTOM_UP) { 
                index = isCPSTopDown == e.isCPSTopDown ? i : NUM_SUBS-1-i;
            }
            pushStyle();
            stroke(0,150,0,100);
            vline(cps[index].pos, e.cps[i].pos);
            popStyle();
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
