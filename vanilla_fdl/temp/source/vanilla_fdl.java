import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class vanilla_fdl extends PApplet {

Graph g;
String data_path = "data/data1.csv";
float Ks = 0.005f;
float Kc = 250;
final float TIME_STEP = 1;
final float DAMPING = 0.9f;

Node cur_node = null;

public void setup() {

    size(800, 600);
    readData();
}

public void readData() {

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

public void mouseDragged() {
    if(g.isHovering()) {
        cur_node.setPosition(new PVector(mouseX, mouseY));
        cur_node.setForce(new PVector(0, 0));
        cur_node.setVelocity(new PVector(0, 0));
    }
}

public void keyPressed() {

    int k = 107; // k = up spring
    int j = 106; // j = down spring

    if(key == j && Ks >= 0.0005f) {
        Ks -= 0.0005f;
    } else if (key == k && Ks <= 0.01f) {
        Ks += 0.0005f;
    }

    int d = 100; // d = up coulomb
    int f = 102; // f = down coulomb

    if(key == f && Kc >= 50) {
        Kc -= 10;
    } else if (key == d && Kc <= 590) {
        Kc += 10;
    }
}

public void draw() {
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
int  darkBlue = color(64, 28, 166);
int lightBlue = color(155, 133, 216);
int white     = color(255, 255, 255);
int black     = color(0, 0, 0);
float maxForce = 0.0f;
float maxKinetic = 0.0f;

final float MIN_HDIST = 1;
final float MIN_CDIST = 0.05f;
final float MIN_ENERGY = 0.0001f;

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
            dist = 0.0f;
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
            dist = 0.05f;;
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
        float ke = 0.0f;

        for(int i = 1; i <= numNodes; i++) {
            Node n = nodes.get(i);
            float x = n.getVelocity().x; 
            float y = n.getVelocity().y;
            float v = sqrt((x * x) + (y * y));

            ke += 1.0f/2.0f *  (n.getMass()) * (v * v);
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
        int s = color(4, 500 * (sqrt(totalEnergy/maxKinetic)), 300);
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
int radius = 30;

public class Node {

    int id;
    int mass;
    int c;

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

    public void setColor(int _c) {
        c = _c;
    }

    public int getColor() {
        return c;
    }

    private void setForceColor() {

        if(isHovering()) {
            if(cur_node != null && cur_node.getID() == id) {
                c = darkBlue;
                colorMode(HSB);
                int sc = color(4, 500 * sqrt(force.mag()/maxForce), 300);
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
public static class Vector {
    public float x, y;

    Vector() {
        x = 0;
        y = 0;
    }

    Vector(float _x, float _y) {
        x = _x;
        y = _y;
    }

    public static Vector add(Vector v1, Vector v2){
        Vector sum = new Vector(v1.x + v2.x, v1.y + v2.y);
        return sum;
    }
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "vanilla_fdl" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
