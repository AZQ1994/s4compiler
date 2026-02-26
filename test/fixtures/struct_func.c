// Struct pointer passed to function
// set_point(p, 100, 200); return p.x + p.y = 300
struct Point {
    int x;
    int y;
};

void set_point(struct Point* p, int x, int y) {
    p->x = x;
    p->y = y;
}

int main() {
    struct Point p;
    set_point(&p, 100, 200);
    return p.x + p.y;
}
