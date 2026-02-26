int add(int a, int b) { return a + b; }
int sub(int a, int b) { return a - b; }

struct Ops { int (*op)(int, int); int val; };

int apply_op(struct Ops *ops, int x) {
    return ops->op(ops->val, x);
}

int main() {
    struct Ops a;
    a.op = &add;
    a.val = 10;
    struct Ops s;
    s.op = &sub;
    s.val = 20;
    int r1 = apply_op(&a, 5);   // add(10, 5) = 15
    int r2 = apply_op(&s, 3);   // sub(20, 3) = 17
    return r1 + r2;             // 32
}
