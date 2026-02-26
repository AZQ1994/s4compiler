// Nested struct: {Point, Point}
// Rect = {{1, 2}, {3, 4}}, return p2.x - p1.y = 3 - 2 = 1
// Changed: return p1.x + p2.y = 1 + 4 = 5
struct Point {
    int x;
    int y;
};

struct Rect {
    struct Point p1;
    struct Point p2;
};

int main() {
    struct Rect r;
    r.p1.x = 1;
    r.p1.y = 2;
    r.p2.x = 3;
    r.p2.y = 4;
    return r.p1.x + r.p2.y;
}
