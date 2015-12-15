ParallelCoords graph;

void setup() {
    size(800, 600);

    graph = new ParallelCoords("./data.csv");
    graph.setRect(width * 0.1, height * 0.1 , width*0.8, height * 0.8);
    graph.init();
    DIST_COEFF_DENOM = graph.h;
}

void draw() {
    clear();
    background(255);
    boxBR.set(mouseX, mouseY);
    graph.update(.01);

    if (boxTL != null)
        vRect(boxTL, boxBR);
    graph.render();
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

PVector boxTL = null;
PVector boxBR = new PVector(0,0);

void vRect(PVector p1, PVector p2)
{
    rect(p1.x,p1.y,p2.x - p1.x, p2.y - p1.y);
}

void keyPressed()
{
    if (key == ' ')
        boxTL = null;
}

void mouseClicked()
{
    if (boxTL == null)
    {
        boxTL = new PVector (mouseX, mouseY);
    }
}

boolean inBox(PVector p)
{
    if (boxTL == null) return false;
    PVector left, right, bottom, top;
    left = boxTL.x < boxBR.x ? boxTL : boxBR;
    right = boxTL.x >= boxBR.x ? boxTL : boxBR;
    top = boxTL.y < boxBR.y ? boxTL : boxBR;
    bottom = boxTL.y >= boxBR.y ? boxTL : boxBR;
    
    return p.x >= left.x && p.x <= right.x && p.y >= top.y && p.y <=
    bottom.y;
}
