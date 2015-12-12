FDEB_Graph graph;

void setup() {
    size(700, 700);
    DIST_COEFF_DENOM = sqrt(width*width + height*height);
    //float dist_apart = random(height/2);
    graph = new FDEB_Graph();

    // RANDOM GEN LINES
    int n_paths = 50;
    BUNDLE_CONST = BUNDLE_CONST / n_paths;
    for (int i = 0; i < n_paths; i++) {
        // random
        graph.addPath(random(width), random(height), random(width), random(height));
    }

    // graph.generate();
    // MANUAL GEN LINES
     graph.addPath(100, 100, 100, 600);
     graph.addPath(150, 100, 150, 600);

     graph.addPath(200, 100, 200, 600);
     graph.addPath(250, 100, 250, 600);
     graph.addPath(300, 100, 300, 600);
     graph.addPath(320, 100, 320, 600);
     graph.addPath(400, 100, 400, 600);
     graph.addPath(450, 100, 450, 600);
     graph.addPath(500, 100, 500, 600);
     graph.addPath(550, 100, 550, 600);
     graph.addPath(600, 100, 600, 600);

    //graph.addPath(100, 100, width/2 + 100, height-100);
    //graph.addPath(width - 100, 100, width/2 - 100, height -100);
}

void draw() {
    background(255);
    float frameSkips = 1000;
    for (int i = 0; i < frameSkips; i++) {
        if (graph.running_time < STARTUP_TIME || graph.total_energy > MAG_CUTOFF)
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
