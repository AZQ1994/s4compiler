#include <string.h>
void clear(void *p, int bytes) {
    memset(p, 0, bytes);
}
int main() {
    int a[3];
    a[0] = 10;
    a[1] = 20;
    a[2] = 30;
    clear(a, 12);
    a[0] = 42;
    return a[0] + a[1] + a[2]; // 42
}
