FDEB_Graph graph;

void setup() {
    size(700, 700);
    //float dist_apart = random(height/2);
    graph = new FDEB_Graph();

    int n_paths = 8;
    for (int i = 0; i < n_paths; i++) {
        // random
        graph.addPath(random(width), random(height), random(width), random(height));
    }

    // graph.generate();
    // Vertical lines test
    //  graph.addPath(380, 400, 300, 200);
    // graph.addPath(350, 400, 410, 250);

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
    graph.render();
}

void mousePressed() {
    setup();
}

void keyPressed() {
   RUBBERBANDER = RUBBERBANDER ? false : true; 
   if (RUBBERBANDER)
        println("BAND ON");
   else
        println("BOND OFF");
}
void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}
