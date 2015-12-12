class FDEB_Graph 
{
    float running_time;
    float total_energy;
    float ct[][] = null;
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;

    FDEB_Graph() {
       nodes = new ArrayList<Node>();
       edges = new ArrayList<Edge>();
       running_time = 0;
       total_energy = 999999;

    }

    void addPath(float x1, float y1, float x2, float y2) {
        addPath(new PVector(x1,y1), new PVector(x2,y2));
    }

    void addPath(PVector p1, PVector p2) {
        Node n1 = new Node(p1, edges.size() * 2);
        Node n2 = new Node(p2, edges.size() * 2 + 1);
        addPath(n1, n2);
    }
    
    void addPath(Node n1, Node n2) {
        nodes.add(n1);
        nodes.add(n2);
        edges.add(new Edge(n1, n2));
    }

    void render() {
        for (Edge e : edges) {
            e.render();
        }
        for (Node n : nodes) {
            n.render();
        }
    }
    
    public void renderBundleForce() {
        for (Edge e1 : edges) {
            for (Edge e2 : edges) {
                e1.drawBundleForce(e2);
            }
        }
    }

    private void generateCT() {
        int numEdges = edges.size();
        ct = new float[numEdges][numEdges];

        for(int i = 0; i < numEdges; i++) {
            for(int j = 0; j < numEdges; j++) {

                if( i != j) {
                    Edge e1 = edges.get(i);
                    Edge e2 = edges.get(j);

                    CPOrder cpo= e1.calcCPOrder(e2);
    
                    float c_ij = e1.getCompatibilityCoefficient(e2, cpo);
                    ct[i][j] = c_ij;
                }
            }
        }
    }

    void update(float t) {

        if(ct == null) {
            generateCT();
        }

        running_time += t;          
        total_energy = 0;
        for (Edge e : edges) {
            e.zeroForces();
            e.applySpringForces();
        }
        // Apply bundling force from each edge to each other edge
        int numEdges = edges.size();
        for(int i = 0; i < numEdges; i++) {
            for(int j = 0; j < numEdges; j++) {
                if( i != j) {
                    Edge e1 = edges.get(i);
                    Edge e2 = edges.get(j);

                    if (ct[i][j] >= COEFF_CUTOFF) {
                        e1.applyBundleForces(e2, ct[i][j]);
                    }
                }
            }
        }
         
        for (Edge e : edges) {
//            if (running_time < STARTUP_TIME || e.getMagnitude() < MAG_CUTOFF) {
                e.update(t);
                total_energy += e.getMagnitude();
//            }<F2>
        }
    }

    void generate() {
       // while (running_time < STARTUP_TIME || total_energy > MAG_CUTOFF) {
           update(.001); 
        //}
    }
}
