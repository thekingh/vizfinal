public static class Vector {
    public float x, y;

    Vector() {
        x = 0;
        y = 0;
    }

    Vector(float _x, float _y) {
        x = _x;
        y = _y;
    }

    public static Vector add(Vector v1, Vector v2){
        Vector sum = new Vector(v1.x + v2.x, v1.y + v2.y);
        return sum;
    }
}
