Node n1;
Node n2;
Node n3;
Node n4;
Edge e1;
Edge e2;

void setup() {
    size(700, 700);
    //float dist_apart = random(height/2);
    float dist_apart = 150;
    n1 = new Node(new PVector(random(width/2), height/2 - dist_apart/2), 1);
    n2 = new Node(new PVector(random(width/2, width), height/2 - dist_apart/2), 2);
    e1 = new Edge(n1, n2);

    n3 = new Node(new PVector(random(width/2), height/2 + dist_apart/2), 1);
    n4 = new Node(new PVector(random(width/2, width), height/2 + dist_apart/2), 2);
    e2 = new Edge(n3, n4);
}

void draw() {
    background(200, 200, 200);

    for (int i = 0; i < 2000; i++) {
    e1.zeroForces();
    e2.zeroForces();

    e1.applySpringForces();
    e2.applySpringForces();

    e1.applyBundleForces(e2);
    e2.applyBundleForces(e1);

    
    e1.update(0.00005);
    e2.update(0.00005);
    }


    n1.render();
    n2.render();
    e1.render();

    n3.render();
    n4.render();
    e2.render();
}

void mousePressed(){
    setup();
}

void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}
