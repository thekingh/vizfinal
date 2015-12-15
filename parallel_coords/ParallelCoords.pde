public class ParallelCoords{
    FDEB_Graph[] graphs;
    int cols;
    Table data;
    float[] vmins;
    float[] vmaxs;
    String[] titles;
    float x,y,w,h;

	public ParallelCoords (String dataFile) {
        data = loadTable(dataFile, "header");
        titles = data.getColumnTitles();
        this.x = 0;
        this.y = 0;
        this.w = width;
        this.h = height;
    }

    public void setRect(float x, float y,float   w,float  h) {
        this.x = x;
        this.y = y;
        this.w = w;
        this.h = h;
    }

    public float scaleX (float v) {
        return lerp(x, x+w, v);
    }

    public float scaleY(float v, String title) {
        int index = data.getColumnIndex(title);
        return lerp(y + h, y, (v - vmins[index]) / (vmaxs[index] - vmins[index]));
    }
    
    public float scaleY(float v, int index) {
        return lerp(y + h, y, (v - vmins[index]) / (vmaxs[index] - vmins[index]));
    }

    private void init() {
        cols = data.getColumnCount();
        graphs = new FDEB_Graph[cols - 1];
        for (int i = 0; i < graphs.length; i++) {
           graphs[i] = new FDEB_Graph(); 
        }
        vmins = new float[cols];
        vmaxs = new float[cols];
        initColBounds();
        int rowID = 0;
        for (TableRow row : data.rows()) {
            for (int col = 0; col < cols-1; col++) {
                float interval = 1 / ((float)cols - 1);
                PVector p1 = new PVector(scaleX(col*interval), 
                                         scaleY(row.getFloat(col), col));
                PVector p2 = new PVector(scaleX((col+1)*interval), 
                                         scaleY(row.getFloat(col+1), col+1)); 
                graphs[col].addPath(p1,p2,rowID);
            }
            rowID++;
        }
    }

    private void initColBounds() {
        cols = data.getColumnCount();
        for (int i = 0; i < cols ; i++)
        {
            String[] col = data.getStringColumn(titles[i]);
            float[] arr = parseFloatArr(col);
            vmins[i] = min(arr);
            vmaxs[i]  = max(arr);
        }
    }

    private float[] parseFloatArr(String[] arr)
    {
        int len = arr.length;
        float[] floatArr = new float[len];
        for (int i = 0; i < len; i++)
        {
            floatArr[i] = Float.parseFloat(arr[i]);
        }
        return floatArr;
    }

    public void update(float t)
    {
        ArrayList<Integer> selectedRows = new ArrayList<Integer>();
        for (FDEB_Graph g : graphs) {
            g.update(t);
        }
        for (FDEB_Graph g : graphs)
        {
            for (Edge e : g.edges)
            {
                if (inBox(e.n1.pos) || inBox(e.n2.pos))
                    selectedRows.add(e.rowID);
            }
        }
        for (FDEB_Graph g : graphs)
        {
            for (Edge e : g.edges)
            {
                e.highlight = selectedRows.contains(e.rowID);
            }
        }
        
    }

    public void render()
    {
        for (FDEB_Graph g : graphs) {
            g.render();
        }
        drawAxes();
    }

    public void drawAxes()
    {
        pushStyle();
        fill(0);
        stroke(0);
        strokeWeight(1);
        for (int col = 0; col < cols; col++) {
            float xx = scaleX(((float)col/(cols-1)));
            line(xx, y, xx, y+h);
            textAlign(CENTER);
            text(titles[col], xx, y - 10);

        }
        popStyle();
    }
}
