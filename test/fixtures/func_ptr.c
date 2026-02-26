int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }

int apply(int (*op)(int, int), int x, int y) {
    return op(x, y);
}

int main() {
    int r1 = apply(&add, 3, 5);    // 8
    int r2 = apply(&sub, 10, 3);   // 7
    return r1 + r2;                 // 15
}
