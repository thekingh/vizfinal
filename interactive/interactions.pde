boolean addingEdge = false;
boolean addingConstraint = false;
boolean selectingFirstNode = false;
Node firstNode = null;
Node secondNode = null;

boolean movingNode = false;
Node moveNode = null;

boolean inInteraction = false;


void keyHandle() {
    if (key == 'n') {
       graph.addNode((float)mouseX, (float)mouseY);
    }
    if (key == 'e') {
        if (inInteraction) return;
        inInteraction = true;
        addingEdge = true;
        selectingFirstNode = true;
    }

    if(key == 'c') {
        if (inInteraction) return;
        inInteraction      = true;
        addingConstraint   = true;
        selectingFirstNode = true;
    }

    if (key == 'r') {
        graph.reset();
    }

    if (key == 'm') {
        if (movingNode) {
            inInteraction = false;
            movingNode = false;
        }
        if (inInteraction) return;

        movingNode = true;
        inInteraction = true;
    }
}

void mouseHandle() {
    if (addingEdge) {
        handleAddEdge();
    } 

    if(addingConstraint) {
        handleAddConstraint();
    }
}

void mouseDragHandle()
{
    if (movingNode)
    {
        if (moveNode == null)
            moveNode = hoveredNode();
        handleMoveNode();
    }
}

void mouseReleased()
{
    moveNode = null;
}

void handleMoveNode()
{
    if (moveNode == null) return; 
    moveNode.pos.set(mouseX,mouseY);
    //update edge directions, CP ordering etc...
    for (Edge e : graph.edges) {
        if (e.n1.id == moveNode.id || e.n2.id == moveNode.id) {
           e.initEdge(); 
        }
    }
    //update graph CPOrder table and coeff table
    graph.generateCT();
}

void highlightNode(Node n)
{
    float x = n.pos.x;
    float y = n.pos.y;
    pushStyle();
    noStroke();
    fill(255,0,0,200);
    ellipse(x,y, NODE_RADIUS + 10, NODE_RADIUS + 10);
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

void handleAddConstraint()
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
        graph.addConstraint(firstNode, secondNode);
        addingConstraint = false;
/*        graph.ct = null;*/
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
        if (PVector.dist(n.pos, mousePos) <= NODE_RADIUS){
            return n;
        }
    }
    return null;
}
