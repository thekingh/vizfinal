FDEB_Graph graph;

Constraint c;

void setup() {
    size(700, 700);
    DIST_COEFF_DENOM = sqrt(width*width + height*height);
    //float dist_apart = random(height/2);
    graph = new FDEB_Graph();

    // RANDOM GEN LINES
    int n_paths = 300;
/*    BUNDLE_CONST = BUNDLE_CONST;*/
    //graph = parseCSV("examples/data.csv");
    for (int i = 0; i < n_paths; i++) {
        // random
        graph.addPath(random(width), random(height), random(width), random(height));
    }

    // graph.generate();
    // MANUAL GEN LINES
/*     graph.addPath(100, 100, 100, 600);*/
/*     graph.addPath(150, 100, 150, 600);*/
/*     graph.addPath(200, 100, 200, 600);*/
/*     graph.addPath(250, 100, 250, 600);*/
/*     graph.addPath(300, 100, 300, 600);*/
/**/
/**/
/*     graph.addConstraint(100, 100, 600, 600, 100.0);*/
/**/
/*     graph.addPath(400, 100, 400, 600);*/
/*     graph.addPath(450, 100, 450, 600);*/
/*     graph.addPath(550, 100, 550, 600);*/
/*     graph.addPath(600, 100, 600, 600);*/
/**/
/*     */
/*    graph.addPath(100, 100, width/2 + 100, height-100);*/
/*    graph.addPath(width - 100, 100, width/2 - 100, height -100);*/
     Edge e = graph.edges.get((int)random(graph.edges.size()));

       graph.addConstraint(300, 380, 300, 300, 2.0);
     graph.addConstraint(e.left.pos.x, e.left.pos.y, e.right.pos.x, e.right.pos.y, 2.0);
    
    int num_constr = 3;
    for (int i = 0; i < num_constr; i++) {
        // random
        graph.addConstraint(random(width), random(height), random(width), random(height), 2.0);
    }
    BUNDLE_CONST = GBUNDLE_CONST / (1.0 * graph.edges.size() * NUM_SUBS);
}

void draw() {
    background(255);
    float frameSkips = 10;
    for (int i = 0; i < frameSkips; i++) {
//        if (graph.running_time < STARTUP_TIME || graph.total_energy > MAG_CUTOFF)
            graph.update(.01);
    }
    if (DRAW_BUNDLE_FORCE && LENSWITCH)
        graph.renderBundleForce();
    graph.render();
}

void mousePressed() {
    
}

void keyPressed() {
    if(key == 'b')
        DRAW_BUNDLE_FORCE = !DRAW_BUNDLE_FORCE;
    if(key == ' ')
        setup();

    if( key == 'c') {
        LENSWITCH = !LENSWITCH;
    }

    if(key == 'a') {
        ANGLESWITCH = !ANGLESWITCH;
    }

    if(key == 'l') {
        BEZLINE = !BEZLINE;
    }

    if(key == 'n') {
        NUM_SUBS += 1;
        println(NUM_SUBS);
        setup();
    }

    if(key == 'g') {
        DEBUG_CONSTR_ON = !DEBUG_CONSTR_ON;
    }
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
