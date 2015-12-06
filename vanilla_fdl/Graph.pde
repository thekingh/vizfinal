color  darkBlue = color(64, 28, 166);
color lightBlue = color(155, 133, 216);
color white     = color(255, 255, 255);
color black     = color(0, 0, 0);
float maxForce = 0.0;
float maxKinetic = 0.0;

final float MIN_HDIST = 1;
final float MIN_CDIST = 0.05;
final float MIN_ENERGY = 0.0001;

public class Graph { 
    int numEdges;
    int numNodes;

    // 2D array of edge weights, -1 if no edge
    int[][] edges; 
    // key is node id, value is node itself
    HashMap<Integer, Node> nodes;

    float totalEnergy;

    Graph() {
        numEdges = 0;
        numNodes = 0;

        edges  = null;
        nodes  = new HashMap<Integer, Node>();
    }

    Graph(int _numNodes, int _numEdges) {
        numNodes = _numNodes;
        numEdges = _numEdges;

        edges  = new int[numNodes+1][numNodes+1]; // apparently not zero based?
        initEdges();
        nodes  = new HashMap<Integer, Node>(numNodes);

        totalEnergy = 100;
    }


    public void initEdges() {
        for(int i = 0; i <= numNodes; i++) {
            for(int j = 0; j <= numNodes; j++) {
                edges[i][j] = -1;
            }
        }
    }

    public void addNode(Node n) {
        nodes.put(n.getID(), n);

        if(numNodes < nodes.size()) {
            numNodes++;
        }
    }

    public void addEdge(int id1, int id2, int weight) {

        // check if edges is not null and graph has nodes
        if(edges == null && numNodes > 0) {
            edges = new int[numNodes + 1][numNodes + 1];
            initEdges();
        }

        // check edge is in bounds of number nodes
        if(id1 <= numNodes  && id2 <= numNodes) {
            // adj mat
            edges[id1][id2] = weight;
            edges[id2][id1] = weight;
        }
    }

    public void printEdges() {
        for(int i = 0; i <= numNodes; i++) {
            for(int j = 0; j <= numNodes; j++) {
                print(edges[i][j] + "\t");
            }
            println();
        }

    }

    public void updateForce(Node n) {

        PVector springForce  = new PVector(0, 0);
        PVector coulombForce = new PVector(0, 0);

        // for all nodes
        for(int i = 1; i <= numNodes; i++) {
            
            if ( i != n.getID()) {
                // make new coulomb force for all nodes (not incl. self)
                PVector cf_i = getCoulombVector(n, nodes.get(i));
                coulombForce.add(cf_i);

                // if edge exists, add a new spring force
                if( edges[n.getID()][i] != -1) {
                    PVector sf_i = getHookesVector(n, nodes.get(i), edges[n.getID()][i]);
                    springForce.add(sf_i);
                }

            }
        }
        // add together all forces and update
        PVector sum = new PVector(0, 0);
        sum.add(springForce);
        sum.add(coulombForce);

        n.setForce(sum);

    }

    public void updatePosition(Node n) {

        // calculate new acceleration
        PVector a   = new PVector(n.getForce().x, n.getForce().y);
                a.div(n.getMass());

        PVector vi  = new PVector(n.getVelocity().x, n.getVelocity().y);     // vi

        PVector vf = new PVector(vi.x, vi.y);    // vf = vi + at
        PVector tmp_a = a;
        tmp_a.mult(TIME_STEP);
        vf.add(tmp_a);                             

        PVector pf = new PVector(n.getPosition().x, n.getPosition().y);    // p = pi + vit + 1/2at^2
        PVector tmp_v = vi;
        tmp_v.mult(TIME_STEP);
        tmp_a.mult(1/2 * TIME_STEP);

        pf.add(tmp_v);
        pf.add(tmp_a);
        
        vf.mult(DAMPING);
        n.setVelocity(vf);

        if(totalEnergy > MIN_ENERGY) {
            n.setPosition(pf);
        }
    }

    public PVector getHookesVector(Node n1, Node n2, int targetLength) {
        

        PVector h = new PVector(0, 0);

        PVector d = new PVector(n2.getPosition().x, n2.getPosition().y);  // vector from  n2 to n1  
        d.sub(n1.getPosition());

        Float dist = d.mag();
        if(dist.isNaN() || abs(dist) < MIN_HDIST) {
            dist = 0.0;
        }
        float diff = targetLength - dist;

        PVector n = d;
        n.normalize();

        n.mult(-1 * Ks * diff);
        h.add(n);

        return h;
    }

    public PVector getCoulombVector(Node n1, Node n2) {
       

        PVector d = new PVector(n2.getPosition().x, n2.getPosition().y);
        d.sub(n1.getPosition());
        Float dist = d.mag();

        if(dist.isNaN() || abs(dist) < MIN_CDIST) {
            dist = 0.05;;
        }

        dist *= dist;

        PVector c = new PVector(d.x, d.y);
        c.normalize();

        c.mult(1/dist);
        c.mult(Kc);
        c.mult(-1);

        return c;
    }

    public void updateTotalEnergy() {
        float ke = 0.0;

        for(int i = 1; i <= numNodes; i++) {
            Node n = nodes.get(i);
            float x = n.getVelocity().x; 
            float y = n.getVelocity().y;
            float v = sqrt((x * x) + (y * y));

            ke += 1.0/2.0 *  (n.getMass()) * (v * v);
        }
        totalEnergy = ke;

        if(ke > maxKinetic) {
            maxKinetic = ke;
        }
    }

    public void updateMaxForce() {
        for(int i = 1; i <= numNodes; i++){
            Node n = nodes.get(i);
            if(n != null) {
                if(n.getForce().mag() > maxForce) {
                    maxForce = n.getForce().mag();
                }
            }
        }
    }

    public boolean isHovering() {
        
        boolean isHovering = false;

        for(int i = 1; i <= numNodes; i++) {
            Node n = nodes.get(i);
            if (n != null) {
                if(n.isHovering()) {
                    cur_node = n;
                    isHovering =  true;
                }
            }
        }

        return isHovering;
    }

    public void render() {
        // 1 based :(

        /************ PHYSICS  **************/

        //update positions of all nodes
        for(int i = 1; i <= numNodes; i++) {
            Node n = nodes.get(i);
            updateForce(n);
        }

        for(int i = 1; i <= numNodes; i++) {
            Node n = nodes.get(i);
            updatePosition(n);
        }
    
        updateTotalEnergy();
        updateMaxForce();


        /************ DRAWING **************/

        //draw frame

        colorMode(HSB);
        color s = color(4, 500 * (sqrt(totalEnergy/maxKinetic)), 300);
        stroke(s);
        strokeWeight(10);
        rect(0, 0, width, height);
        colorMode(RGB);
        stroke(0, 0, 0);
        strokeWeight(1);
        

        //draw lines
        for(int i = 1; i <= numNodes; i++) {
            for(int j = (i + 1); j <= numNodes; j++) {
                if(edges[i][j] != -1) {
                    line(nodes.get(i).getPosition().x, nodes.get(i).getPosition().y,
                         nodes.get(j).getPosition().x, nodes.get(j).getPosition().y);
                }
            }
        }

        // draw nodes
        for(int i = 1; i <= numNodes; i++) {
            Node n = nodes.get(i);
            if(n != null) {
                n.render();
            }
        }
    }
}
