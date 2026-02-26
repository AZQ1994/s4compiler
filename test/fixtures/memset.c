#include <string.h>

struct Data { int a; int b; int c; };

int main() {
    struct Data d;
    memset(&d, 0, sizeof(d));  // 12 bytes = 3 words zeroed
    d.a = 42;
    return d.a + d.b + d.c;   // 42 + 0 + 0 = 42
}
