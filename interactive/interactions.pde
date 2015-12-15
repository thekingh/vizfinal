boolean addingEdge = false;
boolean selectingFirstNode = false;
Node firstNode = null;
Node secondNode = null;

boolean movingNode = true;
Node theMovingNode = null;

boolean inInteraction = false;

void keyHandle() {
    if (key == 'n')
       graph.addNode((float)mouseX, (float)mouseY);
    if (key == 'e')
    {
        if (inInteraction) return;
        inInteraction = true;
        addingEdge = true;
        selectingFirstNode = true;
    }
    if (key == 'r')
    {
        graph.reset();
    }
    if (key == 'm')
    {
        if (inInteraction) return;
        inInteraction = true;
        movingNode = true;
    }
}

void mouseHandle() {
    if (addingEdge) {
        handleAddEdge();
    }
}

void mousePressHandle()
{
    if (!mousePressed) return;
    
    if (movingNode)
    {
        handleMoveNode();
    }
}

void handleMoveNode()
{
    println("handlingMOVE");
    Node n  = hoveredNode();
    if (n == null) return; 
    n.pos.set(mouseX,mouseY);
    //TODO: reset the edges that involve this node...
    graph.ct = null;
    highlightNode(n);
}

void highlightNode(Node n)
{
    float x = n.pos.x;
    float y = n.pos.y;
    pushStyle();
    noStroke();
    fill(255,0,0,200);
    ellipse(x,y, NodeRadius + 10, NodeRadius + 10);
    popStyle();
}

void handleAddEdge()
{
    if (selectingFirstNode) {
        firstNode = hoveredNode();
        if (firstNode == null) return;
        selectingFirstNode = false;
    } else {
        Node n = hoveredNode();
        if (n == null) return;
        if (n.id != firstNode.id)
            secondNode = n;
        graph.addPath(firstNode, secondNode);
        addingEdge = false;
        graph.ct = null;
        firstNode = null;
        secondNode = null;
        inInteraction = false;
    }
}

Node hoveredNode()
{
    PVector mousePos = new PVector(mouseX, mouseY);
    for (Node n : graph.nodes)
    {
        if (PVector.dist(n.pos, mousePos) <= NodeRadius){
            return n;
        }
    }
    return null;
}
