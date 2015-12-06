Graph g;
String data_path = "data/data1.csv";
float Ks = 0.005;
float Kc = 250;
final float TIME_STEP = 1;
final float DAMPING = 0.9;

Node cur_node = null;

void setup() {

    size(800, 600);
    readData();
}

void readData() {

    String[] lines = loadStrings(data_path);
    
    int numNodes = -1;
    int numEdges = -1;
    numNodes = parseInt(lines[0]);
    numEdges = parseInt(lines[numEdges + 1]);


    g = new Graph(numNodes, numEdges);

    // read and make all nodes
    for (int i = 1; i <= numNodes; i++) {
        String[] splitLine = split(lines[i], ",");
        Node n = new Node(parseInt(splitLine[0]), parseInt(splitLine[1]));

        int px = (int)random(width/4, (3* width/4));
        int py = (int)random(width/4, (3* width/4));
/*        int py = height/2;*/
        n.setPosition(new PVector(px, py));

        g.addNode(n);
    }

    // read and make all edges
    for(int i = (numNodes + 2); i < lines.length; i++) {
        String[] splitLine = split(lines[i], ",");
        g.addEdge(parseInt(splitLine[0]), parseInt(splitLine[1]), parseInt(splitLine[2]));
    }

}

void mouseDragged() {
    if(g.isHovering()) {
        cur_node.setPosition(new PVector(mouseX, mouseY));
        cur_node.setForce(new PVector(0, 0));
        cur_node.setVelocity(new PVector(0, 0));
    }
}

void keyPressed() {

    int k = 107; // k = up spring
    int j = 106; // j = down spring

    if(key == j && Ks >= 0.0005) {
        Ks -= 0.0005;
    } else if (key == k && Ks <= 0.01) {
        Ks += 0.0005;
    }

    int d = 100; // d = up coulomb
    int f = 102; // f = down coulomb

    if(key == f && Kc >= 50) {
        Kc -= 10;
    } else if (key == d && Kc <= 590) {
        Kc += 10;
    }
}

void draw() {
    clear();
    background(200, 200, 200);
    g.render();

    String sc = "Spring Constant:       " + Ks;
    String cc = "Coulomb's Constant: " + Kc;
    fill(0, 0, 0);
    text(sc, 10, 10, 300, 25);
    text(cc, 10, 25, 300, 60);
    fill(255, 255, 255);

    if(!mousePressed) {
        cur_node = null;
    } else {
        g.updateTotalEnergy();
        if(cur_node != null) {
            cur_node.setForce(new PVector(0, 0));
            cur_node.setVelocity(new PVector(0, 0));
        }
    }

}
