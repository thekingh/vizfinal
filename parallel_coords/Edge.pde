
public class Edge {

    Node n1, n2; // make ints for optimization?
    ControlPoint[] cps;
    boolean isCPSTopDown;
    float len;
    int rowID; //for parallel coords only
    boolean highlight = false;

    Node left, right;
    Node top, bottom; 
    PVector initState;

    public Edge() {
        this(new Node(), new Node());
    }

    public Edge(Node n1, Node n2, int rowID)
    {
        this(n1, n2);
        this.rowID = rowID;
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

        initState = PVector.sub(right.getPosition(), left.getPosition());
    }

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
        float segmentLength = len / (1.0*NUM_SUBS+1);
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
        float localSF = SPRING_CONST / (1.0*NUM_SUBS+1);
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
    public void applyBundleForces(Edge e, boolean matchingOrder, float c) {

        for (int i = 0; i < NUM_SUBS; i++) {
 //           int index = matchingOrder ?  i : NUM_SUBS-1-i;
            if ( c >= COEFF_CUTOFF)
                cps[i].applyBundleForce(e.cps[i], c);        
        }
    }

    public void applyConstraintForces(Constraint c) {

        /*
            1. find closest point on edge to constraint
            2. find that vector
            3. for all cps that reach constraint within that vector * constant
               apply attractive force
        */


        for(int i = 0; i < NUM_SUBS; i++) {

            PVector edgeCP = cps[i].getPosition();
            PVector constCP = c.getClosestPoint(edgeCP);
            
            if(constCP == null) {
                continue;
            }

            float dist  = PVector.dist(constCP, edgeCP);

            if( dist < MIN_CONSTRAINT_DISTANCE) {
                pushStyle();
                stroke(0,100,0,10);
                popStyle();
                float coeff = c.getGravity();
                cps[i].applyBundleForce(constCP, coeff);
            }
        }


/*        for(int i = 0; i < NUM_SUBS; i++) {*/
/*            float r = 1000000000.0;*/
/*            float coeff = 1;*/
/*            int index = 0;*/
/**/
/*            for (int j = 0; j < c.cps.length; j++) {*/
/*                ControlPoint ccp = c.cps[j];*/
/*                float dist = PVector.dist(ccp.getPosition(), cps[i].getPosition());*/
/*                if ( r < dist ) {*/
/*                    r = min(r,dist);*/
/*                    coeff = c.getGravity() / (r);*/
/*                    index = j;*/
/*               }*/
/*            }*/
/*            */
/*            cps[i].applyBundleForce(c.cps[index], coeff);*/
/*        }*/
    }


    public float getCompatibilityCoefficient(Edge e, CPOrder cpo) {
        float c = 1.0;
        
        if (ANGLESWITCH) {
            c *= getAngleCoefficient(e, cpo);
        } 

        if(LENSWITCH) {
            c *= getLengthCoefficient(e);
        }

        if (DISTSWITCH) {
            c *= getDistanceCoefficent(e);
        }
        return c;
    }

    public float getLengthCoefficient(Edge e) {

        float avgLen = (this.len + e.len)/2;
        float maxLen = max(this.len, e.len);

        float lc = 1 - ((maxLen - avgLen)/avgLen);

        //assert(lc <= 1.0);
        return lc;
    }

    public float getAngleCoefficient(Edge e, CPOrder cpo) {
        float m = 1;
        if (cpo == CPOrder.TOP_DOWN || cpo == CPOrder.BOTTOM_UP) { 
            m = (isCPSTopDown == e.isCPSTopDown) ? 1 : -1;
        }

        float ac = PVector.dot(this.initState, PVector.mult(e.initState, m));
        ac /= (this.len * e.len);
/*        return abs(ac);*/
        if (ac*ac > 1)
            println(ac*ac);
        //assert(ac*ac <=1.1); //TODO: quick check, we get floating point errors
        return ac * ac;
    }

    public float getDistanceCoefficent(Edge e)
    {
        PVector herMid = getMidpoint(this);
        PVector hisMid = getMidpoint(e); 
        //assert(1.0 - PVector.sub(herMid, hisMid).mag()/DIST_COEFF_DENOM <= 1.0);
        return 1.0 - PVector.sub(herMid, hisMid).mag()/DIST_COEFF_DENOM;
    }

    private PVector getMidpoint(Edge e)
    {
        PVector mid = PVector.add(e.left.pos, 
                                  PVector.mult(PVector.sub(e.right.pos,e.left.pos),
                                  0.5));
        return mid;
    }

    public void drawBundleForce(Edge e)
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

    public void renderNoBundle()
    {
        pushStyle();
        color c = color(0, 200,200);    
        stroke(c);
        strokeWeight(EDGE_WEIGHT);
        vline(left.pos, right.pos);
        popStyle();
    }

    public void render() {
        // Draws a ghost of pre-bundled edge
//        if (SHOW_ORIGINAL) {
//            pushStyle();
//            fill(0,.02);
//            float pixel_spacing = 12;
//            float n_pts = PVector.dist(left.pos, right.pos) / pixel_spacing;
//            for (int i = 0; i < n_pts; i++) {
//                PVector pt = PVector.lerp(left.pos, right.pos, i/n_pts);
//                ellipse(pt.x, pt.y, 1, 1);
//            }
//            popStyle();
//        }

        pushStyle();
        color c = color (0,0,200,60);
        if (boxTL != null) {
            if (highlight)
                c = color(200,0,0,60);
            else
            {
                c = color(0,0,200,10);
                if(!SHOW_UNHIGHLIGHT)
                    return;
            }
        }
        stroke(c);
        strokeWeight(EDGE_WEIGHT);
        if(!BEZLINE) {
            for(int i = 0; i <= NUM_SUBS; i++) {

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
        } else {
            PVector[] bezCPS = new PVector[NUM_SUBS+2];   
            bezCPS[0] = left.pos;
            bezCPS[NUM_SUBS+1] = right.pos;
            for(int i = 0; i < NUM_SUBS; i++) {
                bezCPS[i+1] = cps[i].pos;
            }
            bezLine(bezCPS);
        }
        popStyle();
    }

}
