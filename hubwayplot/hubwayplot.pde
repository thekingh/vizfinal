HubwayBundle hubway;

void setup() {
    size(700, 700);
    //float dist_apart = random(height/2);
    hubway = new HubwayBundle();

    // graph.generate();
    // Vertical lines test
    //  graph.addPath(380, 400, 300, 200);
    // graph.addPath(350, 400, 410, 250);

//      graph.addPath(380, 400, 300, 200);
//      graph.addPath(380, 400, 300, 200);
    //graph.addPath(100, 100, width/2 + 100, height-100);
    //graph.addPath(width - 100, 100, width/2 - 100, height -100);
}

void draw() {
    background(200, 200, 200);
    float frameSkips = 500;
    for (int i = 0; i < frameSkips; i++) {
        hubway.update();
        //if (graph.running_time < STARTUP_TIME || graph.total_energy > MAG_CUTOFF)
        //    graph.update(.001);
    }
    hubway.render();
}

void mousePressed() {
    
}

void keyPressed() {
    if(key == ' ')
        setup();
    if (key == 'r')
   RUBBERBANDER = RUBBERBANDER ? false : true; 
   if (RUBBERBANDER)
        println("BAND ON");
   else
        println("BOND OFF");
}
void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}
