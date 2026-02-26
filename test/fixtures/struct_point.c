// Flat struct: {i32, i32}
// Point.x = 10, Point.y = 20, return x + y = 30
struct Point {
    int x;
    int y;
};

int main() {
    struct Point p;
    p.x = 10;
    p.y = 20;
    return p.x + p.y;
}
