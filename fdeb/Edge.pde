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

    // always populate left to right
    private void initControlPoints() {
        
        if(right == null || left == null) {
            println("FUCK");
        }
        
        PVector dir = PVector.sub(right.getPosition(), left.getPosition()); //watch out if n1 posn == n2 posn
        dir.normalize();
        float segmentLength = len / (NUM_SUBS+1);
        println("SL: " + segmentLength);
        for (int i = 0; i < NUM_SUBS; i++) {
            cps[i] = new ControlPoint(PVector.add(left.getPosition(), PVector.mult(dir, segmentLength * (i+1))));
            println("cpx: " + cps[i].getPosition().x);
        }
    }

    public void render() {
        pushStyle();
        fill(0);
        
        for(int i = 0; i < NUM_SUBS; i++) {
            if(i == 0) {
                vline(left.getPosition(), cps[i].getPosition());
            } else if (i == NUM_SUBS - 1) {
                vline(cps[i].getPosition(), right.getPosition());
            } else {
                vline(cps[i].getPosition(), cps[i+1].getPosition());
            }

            //TODO cp.render()
            ellipse(cps[i].getPosition().x, cps[i].getPosition().y, 10, 10);
        }

        popStyle();
    }

}
