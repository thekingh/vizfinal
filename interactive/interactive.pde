FDEB_Graph graph;

Constraint c;

void setup() {
    size(700, 700);
    DIST_COEFF_DENOM = sqrt(width*width + height*height);
    //float dist_apart = random(height/2);
    graph = new FDEB_Graph();

    // RANDOM GEN LINES
    int n_paths = 10;
    for (int i = 0; i < n_paths; i++) {
        graph.addPath(random(width), random(height), random(width), random(height));
    }
}

void draw() {
    background(255);
    graph.update(.005);
    if (DRAW_BUNDLE_FORCE && LENSWITCH)
        graph.renderBundleForce();
    graph.render();
    mousePressHandle();
}

void mouseClicked() {
    println("clicked");
    mouseHandle();
}

void keyPressed() {
    keyHandle(); 
    if(key == 'l')
        BEZLINE = !BEZLINE;
    if(key == 'b')
        DRAW_BUNDLE_FORCE = !DRAW_BUNDLE_FORCE;
    if(key == ' ')
        setup();
}

void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}

void bezLine(PVector[] cps) {
    pushStyle();
    noFill();
    int sz = cps.length;
    if (sz == 0)
        return;
    beginShape();
    float x1 = cps[0].x;
    float y1 = cps[0].y;
    float xc = 0.0;
    float yc = 0.0;
    float x2 = 0.0;
    float y2 = 0.0;
    vertex(x1,y1);
    for ( int i = 1; i< sz - 2; ++i) {
        xc = cps[i].x;
        yc = cps[i].y;
        x2 = (xc + cps[i+1].x)*0.5;
        y2 = (yc + cps[i+1].y)*0.5;
        bezierVertex((x1 + 2.0*xc)/3.0,(y1 + 2.0*yc)/3.0,
                  (2.0*xc + x2)/3.0,(2.0*yc + y2)/3.0,x2,y2);
        x1 = x2;
        y1 = y2;
    }
    xc = cps[sz-2].x;
    yc = cps[sz-2].y;
    x2 = cps[sz-1].x;
    y2 = cps[sz-1].y;
    bezierVertex((x1 + 2.0*xc)/3.0,(y1 + 2.0*yc)/3.0,
         (2.0*xc + x2)/3.0,(2.0*yc + y2)/3.0,x2,y2);
    endShape();
    popStyle();
}
