class FDEB_Graph 
{
    float running_time;
    float total_energy;
    float ct[][] = null;
    boolean cpoTable[][] = null;
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;
    ArrayList<Constraint> constraints;

    FDEB_Graph() {
       nodes       = new ArrayList<Node>();
       edges       = new ArrayList<Edge>();
       constraints = new ArrayList<Constraint>();
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

    void addConstraint(float x1, float y1, float x2, float y2, float g) {
        Node n1 = new Node(new PVector(x1, y1), edges.size() * 2);
        Node n2 = new Node(new PVector(x2, y2), edges.size() * 2 + 1);

        Constraint c =  new Constraint(n1, n2, g);

        constraints.add(c);
    }

    void render() {
        for (Edge e : edges) {
            if (SHOW_ORIGINAL)
                e.renderNoBundle();
                e.render();
        }
        for (Constraint c : constraints) {   
            c.render();
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
        int ignoreCount = 0;
        ct = new float[numEdges][numEdges];
        cpoTable = new boolean[numEdges][numEdges];

        for(int i = 0; i < numEdges; i++) {
            Edge e1 = edges.get(i);
            for(int j = 0; j < numEdges; j++) {
                if( i != j) {
                    Edge e2 = edges.get(j);

                    CPOrder cpo= e1.calcCPOrder(e2);
                    // fill cpoTable, which tells bundleforce which way to
                    // iterate
                    if (cpo == CPOrder.TOP_DOWN || cpo == CPOrder.BOTTOM_UP)
                    {
                        cpoTable[i][j] = e1.isCPSTopDown == e2.isCPSTopDown;
                    } else {
                        cpoTable[i][j] = true;
                    }
                    float c_ij = e1.getCompatibilityCoefficient(e2, cpo);
                    if (c_ij < COEFF_CUTOFF)
                        ignoreCount++;
                    assert(c_ij <= 1.0);
                    ct[i][j] = c_ij;
                }
            }
        }


        println("Edge Interactions: ", numEdges*numEdges, "Ignored interactions:" 
        ,ignoreCount); 
    }

    void update(float t) {

        if(ct == null) {
            generateCT();
            BUNDLE_CONST = GBUNDLE_CONST / (1.0 * graph.edges.size() * NUM_SUBS);
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
            Edge e1 = edges.get(i);

            // loop through all other edges
            for(int j = 0; j < numEdges; j++) {
                if( i != j) {
                    Edge e2 = edges.get(j);

                    if (ct[i][j] >= COEFF_CUTOFF) {
                        e1.applyBundleForces(e2,cpoTable[i][j], ct[i][j]);
                    }

                }
            }
            
            // loop through all constraints
            for(int k = 0; k < constraints.size(); k++ ) {
                Constraint c = constraints.get(k);
                if (DEBUG_CONSTR_ON)
                    e1.applyConstraintForces(c);
            }
        }
         
        for (Edge e : edges) {
                e.update(t);
        }
    }

    void generate() {
           update(.001); 
    }
}
