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

public class fdeb extends PApplet {

Node n1;
Node n2;
Edge e1;

public void setup() {
    size(700, 700);
    n1 = new Node(new PVector(width/4, height/2), 1);
    n2 = new Node(new PVector(3 *width/4, height/2), 2);
    e1 = new Edge(n1, n2);
}

public void draw() {
    background(200, 200, 200);
    n1.render();
    n2.render();
    e1.render();
}

public void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}
public class ControlPoint {

    PVector pos, v, a;

    public ControlPoint() {
        this(new PVector(0, 0));
    }

    public ControlPoint(PVector pos) {
        this.pos = pos;
        v = new PVector(0, 0);
        a = new PVector(0, 0);
    }

    public PVector getPosition() {
        return pos;
    }

    public PVector getVelocity() {
        return v;
    }

    public PVector getAcceleration() {
        return a;
    }
}
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
int NodeColor  = color(255, 0, 0);
float NodeRadius = 7.0f;

public class Node {

    PVector pos;
    int id;

    public Node() {
        this(new PVector(0, 0), -1);
    }

    public Node(PVector p, int id) {
        this.id = id;
        this.pos = p;
    }

    public PVector getPosition() {
        return pos;
    }

    public int getID() {
        return id;
    }

    public void render() {
        
        pushStyle();
            
            fill(NodeColor);
            ellipse(pos.x, pos.y, NodeRadius*2, NodeRadius*2);

        popStyle();
    }

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "fdeb" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
