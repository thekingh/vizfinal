Node n1;
Node n2;
Edge e1;

void setup() {
    size(700, 700);
    n1 = new Node(new PVector(width/4, height/2), 1);
    n2 = new Node(new PVector(3 *width/4, height/2), 2);
    e1 = new Edge(n1, n2);
}

void draw() {
    background(200, 200, 200);
    n1.render();
    n2.render();
    e1.render();
}

void vline(PVector p1, PVector p2) {
    line(p1.x, p1.y, p2.x, p2.y);
}
