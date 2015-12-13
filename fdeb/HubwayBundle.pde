import java.util.Map;


class HubwayBundle {
    PGraphics hubmap;
    HashMap<Integer, PVector> stations;
    String data_folder = "../data/";
    PVector latrange;
    PVector lonrange;
    FDEB_Graph graph;
    int max_id = 0;
    
    HubwayBundle()
    {
        stations = new HashMap<Integer, PVector>(145);

        buildStations(data_folder + "hubway_stations.csv");
        graph = generateMap(data_folder + "hubway_trips.csv");
    }

    void buildStations(String file)
    {
        String lines[] = loadStrings(file);
        for (int i = 1; i < lines.length; i++) {
            String line[] = split(lines[i], ",");
            Integer id = Integer.parseInt(line[0]);
            float lat = Float.parseFloat(line[4]);
            float lon = Float.parseFloat(line[5]);
            
            if (i == 1) {
                latrange = new PVector(lat, lat);
                lonrange = new PVector(lon, lon);
            } else {
                if (lat < latrange.x) latrange.x = lat;
                if (lat > latrange.y) latrange.y = lat;
                if (lon < lonrange.x) lonrange.x = lon;
                if (lon > lonrange.y) lonrange.y = lon;
            }
            max_id = max(id, max_id);
            stations.put(id, new PVector(lat, lon));
        }
    }

    FDEB_Graph generateMap(String file) {
        FDEB_Graph graph = new FDEB_Graph();
           
        float latr = latrange.y - latrange.x;
        float lonr = lonrange.y - lonrange.x;
        String lines[] = loadStrings(file);
        //int cutoff = (int) (lines.length * .01);
        int cutoff = 600;
        int plotted = 0;
        
        // matrix if path already exists
        int n = max_id; 
        boolean[][] exists = new boolean[n][n];
        
        for (int i = 0; i < n; i++) { 
            for (int j = 0; j < n; j++) { 
                exists[i][j] = false;
            }
        }

        for (int i = 1; plotted < cutoff && i < lines.length; i++) {
        //while (plotted < cutoff) {
            //int i = (int)random(1, lines.length-2);
            String line[] = split(lines[i], ",");
            try
            {
                Integer start_id = Integer.parseInt(line[5]);
                Integer end_id   = Integer.parseInt(line[7]);

                // Select for paths relative to one station
               // int[] station = {73,54}; // Harvard Brattle, Tremont
               // boolean filter = true;
               // for (int s=0; s<2; s++) {
               //     if (start_id == s || end_id == s) {
               //         filter = false;
               //         break;
               //     }
               // }
               // if (filter) continue;
               //int station = 73;
               //if (start_id != station && end_id != station) continue;

                // Not a path to itself or a already existing path
                if (start_id == end_id || 
                    exists[start_id][end_id] ||
                    exists[end_id][start_id]) continue;
                PVector spos = stations.get(start_id);
                PVector epos = stations.get(end_id);
                graph.addPath(scaleX(spos.x),
                              scaleY(spos.y),
                              scaleX(epos.x),
                              scaleY(epos.y));
                exists[start_id][end_id] = true; 
                exists[end_id][start_id] = true;
            } catch (NumberFormatException e) {
                continue;
            }
            plotted++;
        }

        return graph;
    }

    float scaleY (float v)
    {
        return lerp(50, height - 50, (v - lonrange.x) / (lonrange.y - lonrange.x));
    }

    float scaleX (float v)
    {
        return lerp(50, width - 50, (v - latrange.x) / (latrange.y - latrange.x));
    }

    void update() {
        graph.update(.01);
    }

    void render() {
        graph.render();
    }
}
