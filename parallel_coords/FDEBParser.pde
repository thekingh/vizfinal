FDEB_Graph parseCSV(String filename) {
    FDEB_Graph graph = new FDEB_Graph();

    String[] lines = loadStrings(filename);

    for (int i = 0; i < lines.length; i++) {
        String[] line = split(lines[i], ",");
        int[] pts = new int[4];
        for (int j = 0; j < 4; j++) {
            pts[j] = Integer.parseInt(line[j]);
        }

        graph.addPath(pts[0],pts[1],pts[2],pts[3]);
    }

    return graph;
}
