FDEB_Graph graph;

void setup() {
    size(700, 700);
    //float dist_apart = random(height/2);
    graph = new FDEB_Graph();

    int n_paths = 8;
    for (int i = 0; i < n_paths; i++) {
        graph.addPath(random(width), random(height), random(width), random(height));
    }
}

void draw() {
    background(200, 200, 200);
    float frameSkips = 300;
    for (int i = 0; i < frameSkips; i++) {
        graph.update(.001);
    }
    graph.render();
}

void mousePressed(){
    setup();
}

void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}
