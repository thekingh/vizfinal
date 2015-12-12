FDEB_Graph graph;

void setup() {
    size(700, 700);
    //float dist_apart = random(height/2);
    graph = new FDEB_Graph();

    // RANDOM GEN LINES
    int n_paths = 15;
    for (int i = 0; i < n_paths; i++) {
        // random
        graph.addPath(random(width), random(height), random(width), random(height));
    }

    // graph.generate();
    // MANUAL GEN LINES
     graph.addPath(240, 200, 460, 200);
     graph.addPath(240, 200, 500, 630);

    //graph.addPath(100, 100, width/2 + 100, height-100);
    //graph.addPath(width - 100, 100, width/2 - 100, height -100);
}

void draw() {
    background(200, 200, 200);
    float frameSkips = 500;
    for (int i = 0; i < frameSkips; i++) {
        if (graph.running_time < STARTUP_TIME || graph.total_energy > MAG_CUTOFF)
            graph.update(.001);
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
    if (key == 'r')
   RUBBERBANDER = RUBBERBANDER ? false : true; 
   if (RUBBERBANDER)
        println("BAND ON");
   else
        println("BOND OFF");

    if( key == 'c') {
        LENSWITCH = !LENSWITCH;
    }

    if(key == 'a') {
        ANGLESWITCH = !ANGLESWITCH;
    }
}
void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}
