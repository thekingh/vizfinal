public class ParallelCoords{
    FDEB_Graph graph;
    Table data;
	public ParallelCoords (String dataFile) {
        data = loadTable(path, "header");
        header = data.getColumnTitles();
	}

}
