import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Map; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class interactive extends PApplet {

FDEB_Graph graph;

Constraint c;

public void setup() {
    size(700, 700);
    DIST_COEFF_DENOM = sqrt(width*width + height*height);
    //float dist_apart = random(height/2);
    graph = new FDEB_Graph();

    // RANDOM GEN LINES
    int n_paths = 100;
    BUNDLE_CONST = BUNDLE_CONST;
    for (int i = 0; i < n_paths; i++) {
        graph.addPath(random(width), random(height), random(width), random(height));
    }
}

public void draw() {
    background(255);
    float frameSkips = 1000;
    for (int i = 0; i < frameSkips; i++) {
            graph.update(.01f);
    }
    if (DRAW_BUNDLE_FORCE && LENSWITCH)
        graph.renderBundleForce();
    graph.render();
}

public void mousePressed() {
    
}

public void keyPressed() {
    if(key == 'l')
        BEZLINE = !BEZLINE;
    if(key == 'b')
        DRAW_BUNDLE_FORCE = !DRAW_BUNDLE_FORCE;
    if(key == ' ')
        setup();
}

public void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}

public void bezLine(PVector[] cps) {
    pushStyle();
    noFill();
    int sz = cps.length;
    if (sz == 0)
        return;
    beginShape();
    float x1 = cps[0].x;
    float y1 = cps[0].y;
    float xc = 0.0f;
    float yc = 0.0f;
    float x2 = 0.0f;
    float y2 = 0.0f;
    vertex(x1,y1);
    for ( int i = 1; i< sz - 2; ++i) {
        xc = cps[i].x;
        yc = cps[i].y;
        x2 = (xc + cps[i+1].x)*0.5f;
        y2 = (yc + cps[i+1].y)*0.5f;
        bezierVertex((x1 + 2.0f*xc)/3.0f,(y1 + 2.0f*yc)/3.0f,
                  (2.0f*xc + x2)/3.0f,(2.0f*yc + y2)/3.0f,x2,y2);
        x1 = x2;
        y1 = y2;
    }
    xc = cps[sz-2].x;
    yc = cps[sz-2].y;
    x2 = cps[sz-1].x;
    y2 = cps[sz-1].y;
    bezierVertex((x1 + 2.0f*xc)/3.0f,(y1 + 2.0f*yc)/3.0f,
         (2.0f*xc + x2)/3.0f,(2.0f*yc + y2)/3.0f,x2,y2);
    endShape();
    popStyle();
}
public class Constraint extends Edge {
    
    float gravity;
    
    public Constraint() {
        this(new Node(), new Node(), 1);
    }

    public Constraint(Node n1, Node n2) {
        this(n1, n2, 1);
    }

    public Constraint(Node n1, Node n2, float gravity) {
        super(n1, n2);
        this.gravity = gravity;
    }

    public float getGravity() {
        return gravity;
    }

    public void setGravity(float newGravity) {
        this.gravity = newGravity; 
    }

    public void applySpringForces() {
        return;
    }

    public void applyBundleForces(Edge e, float c) {
        return;
    }

    public void render() {
        
        ellipse(n1.getPosition().x, n1.getPosition().y, 2, 2);
        ellipse(n2.getPosition().x, n2.getPosition().y, 2, 2);

        stroke(255, 0, 0);
        line(n1.getPosition().x, n1.getPosition().y,
             n2.getPosition().x, n2.getPosition().y);

    }
}
public class ControlPoint {
    
    PVector pos, v, a, f;

    public ControlPoint() {
        this(new PVector(0, 0));
    }

    public ControlPoint(PVector pos) {
        this.pos = pos;
        v = new PVector(0, 0);
        a = new PVector(0, 0);
        f = new PVector(0, 0);
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

    public PVector getForce() {
        return f;
    }

    public void zeroForce() {
        f.mult(0);
    }

    // posn = position of connected node
    // Note: springs between control points are zero-length springs
    public void applySpringForce(PVector toPos, float len) {
        
        // normalized vector from this cp to toPos
        PVector force = PVector.sub(toPos, pos);
        force.normalize();

        float dist = PVector.dist(pos, toPos);
        
        // Update force
        f.add(PVector.mult(force, dist * SPRING_CONST / ( (len))));
    }

    // applies attraction force from given control point onto this control point
    public void applyBundleForce(ControlPoint cp, float coeff) {
        PVector force = PVector.sub(cp.getPosition(), pos);
        force.normalize();
        
        float r = PVector.dist(pos, cp.pos);
        if (r < CP_MIN_DIST) return;
/*        force.mult(BUNDLE_CONST/(r*r));*/ // BC = 20000
        force.mult(BUNDLE_CONST / r); // BC = 8
        force.mult(coeff);
        f.add(force);
    }

    public void update(float t) {
        PVector dampF = new PVector(v.x, v.y);
        dampF = PVector.mult(v,-1 * DAMPCONST);
        f.add(dampF);

        a = f;
        pos = PVector.add(pos, PVector.add((PVector.mult(v, t)),
                               PVector.mult(a, 0.5f*t*t)));
        v = PVector.add(v, PVector.mult(a,t));

    }

    public void render(float radius) {
        pushStyle();
        fill(0,0,255);
        ellipse(pos.x, pos.y, radius * 2, radius * 2);
        popStyle();
    }
}
final int NUM_SUBS = 16;

public class Edge {

    Node n1, n2; // make ints for optimization?
    ControlPoint[] cps;
    boolean isCPSTopDown;
    float len;

    Node left, right;
    Node top, bottom; 
    PVector initState;

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

        initState = PVector.sub(right.getPosition(), left.getPosition());
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
        return (angle > PI*.25f && angle < PI * .75f) ||
               (angle > PI*1.25f && angle < PI * 1.75f);
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
        float segmentLength = len / (1.0f*NUM_SUBS+1);
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
            int index = matchingOrder ?  i : NUM_SUBS-1-i;
            if ( c >= COEFF_CUTOFF)
                cps[index].applyBundleForce(e.cps[i], c);        
        }
    }


    public float getCompatibilityCoefficient(Edge e, CPOrder cpo) {
        float c = 1.0f;
        
        if (ANGLESWITCH) {
            c *= getAngleCoefficient(e, cpo);
        } 

        if(LENSWITCH) {
            c *= getLengthCoefficient(e);
        }

        if (DISTSWITCH) {
            c *= getDistanceCoefficent(e);
        }
/*        println("len coeff: " + c);*/
        /* TODO more constraints lol */

        return c;
    }

    public float getLengthCoefficient(Edge e) {

        float avgLen = (this.len + e.len)/2;
        float maxLen = max(this.len, e.len);

        float lc = 1 - ((maxLen - avgLen)/avgLen);

        assert(lc <= 1.0f);
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
        assert(ac*ac <=1.1f); //TODO: quick check, we get floating point errors
        return ac * ac;
    }

    public float getDistanceCoefficent(Edge e)
    {
        PVector herMid = getMidpoint(this);
        PVector hisMid = getMidpoint(e); 
        assert(1.0f - PVector.sub(herMid, hisMid).mag()/DIST_COEFF_DENOM <= 1.0f);
        return 1.0f - PVector.sub(herMid, hisMid).mag()/DIST_COEFF_DENOM;
    }

    private PVector getMidpoint(Edge e)
    {
        PVector mid = PVector.add(e.left.pos, 
                                  PVector.mult(PVector.sub(e.right.pos,e.left.pos),
                                  0.5f));
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

    public void render() {

        // Draws a ghost of pre-bundled edge
        if (SHOW_ORIGINAL) {
            pushStyle();
            fill(0,.02f);
            float pixel_spacing = 12;
            float n_pts = PVector.dist(left.pos, right.pos) / pixel_spacing;
            for (int i = 0; i < n_pts; i++) {
                PVector pt = PVector.lerp(left.pos, right.pos, i/n_pts);
                ellipse(pt.x, pt.y, 1, 1);
            }
            popStyle();
        }

        pushStyle();
        int c = color(0, 0,200, 50);    
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
class FDEB_Graph 
{
    float running_time;
    float total_energy;
    float ct[][] = null;
    boolean cpoTable[][] = null;
    ArrayList<Node> nodes;
    ArrayList<Edge> edges;

    FDEB_Graph() {
       nodes = new ArrayList<Node>();
       edges = new ArrayList<Edge>();
       running_time = 0;
       total_energy = 999999;
    }

    public void addPath(float x1, float y1, float x2, float y2) {
        addPath(new PVector(x1,y1), new PVector(x2,y2));
    }

    public void addPath(PVector p1, PVector p2) {
        Node n1 = new Node(p1, edges.size() * 2);
        Node n2 = new Node(p2, edges.size() * 2 + 1);
        addPath(n1, n2);
    }
    
    public void addPath(Node n1, Node n2) {
        nodes.add(n1);
        nodes.add(n2);
        edges.add(new Edge(n1, n2));
    }

    public void addConstraint(float x1, float y1, float x2, float y2, float g) {
        Node n1 = new Node(new PVector(x1, y1), edges.size() * 2);
        Node n2 = new Node(new PVector(x2, y2), edges.size() * 2 + 1);

        Constraint c =  new Constraint(n1, n2, g);

        edges.add((Edge)c);
         
    }

    public void render() {
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
                    assert(c_ij <= 1.0f);
                    ct[i][j] = c_ij;
                }
            }
        }


        println("Edge Interactions: ", numEdges*numEdges, "Ignored interactions:" 
        ,ignoreCount); 
    }

    public void update(float t) {

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
                    Edge e1 = edges.get(i);
            for(int j = 0; j < numEdges; j++) {
                if( i != j) {
                    Edge e2 = edges.get(j);

                    if (ct[i][j] >= COEFF_CUTOFF) {
                        e1.applyBundleForces(e2,cpoTable[i][j], ct[i][j]);
                    }

                }
            }
        }
         
        for (Edge e : edges) {
                e.update(t);
        }
    }

    public void generate() {
           update(.001f); 
    }
}



class HubwayBundle {
    PGraphics hubmap;
    HashMap<Integer, PVector> stations;
    String data_folder = "../data/";
    PVector latrange;
    PVector lonrange;
    FDEB_Graph graph;
    int max_id = 0;
    
    HubwayBundle()
    {
        stations = new HashMap<Integer, PVector>(145);

        buildStations(data_folder + "hubway_stations.csv");
        graph = generateMap(data_folder + "hubway_trips.csv");
    }

    public void buildStations(String file)
    {
        String lines[] = loadStrings(file);
        for (int i = 1; i < lines.length; i++) {
            String line[] = split(lines[i], ",");
            Integer id = Integer.parseInt(line[0]);
            float lat = Float.parseFloat(line[4]);
            float lon = Float.parseFloat(line[5]);
            
            if (i == 1) {
                latrange = new PVector(lat, lat);
                lonrange = new PVector(lon, lon);
            } else {
                if (lat < latrange.x) latrange.x = lat;
                if (lat > latrange.y) latrange.y = lat;
                if (lon < lonrange.x) lonrange.x = lon;
                if (lon > lonrange.y) lonrange.y = lon;
            }
            max_id = max(id, max_id);
            stations.put(id, new PVector(lat, lon));
        }
    }

    public FDEB_Graph generateMap(String file) {
        FDEB_Graph graph = new FDEB_Graph();
           
        float latr = latrange.y - latrange.x;
        float lonr = lonrange.y - lonrange.x;
        String lines[] = loadStrings(file);
        //int cutoff = (int) (lines.length * .01);
        int cutoff = 600;
        int plotted = 0;
        
        // matrix if path already exists
        int n = max_id; 
        boolean[][] exists = new boolean[n][n];
        
        for (int i = 0; i < n; i++) { 
            for (int j = 0; j < n; j++) { 
                exists[i][j] = false;
            }
        }

        for (int i = 1; plotted < cutoff && i < lines.length; i++) {
        //while (plotted < cutoff) {
            //int i = (int)random(1, lines.length-2);
            String line[] = split(lines[i], ",");
            try
            {
                Integer start_id = Integer.parseInt(line[5]);
                Integer end_id   = Integer.parseInt(line[7]);

                // Select for paths relative to one station
               // int[] station = {73,54}; // Harvard Brattle, Tremont
               // boolean filter = true;
               // for (int s=0; s<2; s++) {
               //     if (start_id == s || end_id == s) {
               //         filter = false;
               //         break;
               //     }
               // }
               // if (filter) continue;
               //int station = 73;
               //if (start_id != station && end_id != station) continue;

                // Not a path to itself or a already existing path
                if (start_id == end_id || 
                    exists[start_id][end_id] ||
                    exists[end_id][start_id]) continue;
                PVector spos = stations.get(start_id);
                PVector epos = stations.get(end_id);
                graph.addPath(scaleX(spos.x),
                              scaleY(spos.y),
                              scaleX(epos.x),
                              scaleY(epos.y));
                exists[start_id][end_id] = true; 
                exists[end_id][start_id] = true;
            } catch (NumberFormatException e) {
                continue;
            }
            plotted++;
        }

        return graph;
    }

    public float scaleY (float v)
    {
        return lerp(50, height - 50, (v - lonrange.x) / (lonrange.y - lonrange.x));
    }

    public float scaleX (float v)
    {
        return lerp(50, width - 50, (v - latrange.x) / (latrange.y - latrange.x));
    }

    public void update() {
        graph.update(.01f);
    }

    public void render() {
        graph.render();
    }
}
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
            noStroke();
            fill(NODE_COLOR);
            ellipse(pos.x, pos.y, NODE_RADIUS*2, NODE_RADIUS*2);
        popStyle();
    }

}
float SPRING_CONST = 1500;
float BUNDLE_CONST = 122;
float DAMPCONST = 0.7f;
float DIST_COEFF_DENOM = max(width,height);
boolean SHOW_ORIGINAL = false;
float STARTUP_TIME = 100;
float MAG_CUTOFF = 4;
float COEFF_CUTOFF = 0.7f;
float CP_MIN_DIST = 7;

boolean BEZLINE = true && false;
boolean DRAW_BUNDLE_FORCE = false;
boolean LENSWITCH = true;
boolean ANGLESWITCH = true;
boolean DISTSWITCH = true;

float NODE_COLOR = 0xff666666;
float NODE_RADIUS = 5;
float EDGE_WEIGHT = 1;
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "interactive" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
