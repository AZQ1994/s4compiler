// Test constant specialization for multiplication
// Expected return: 77
int main() {
    int x = 7;
    int a = x * 0;    // 0
    int b = x * 1;    // 7
    int c = x * 2;    // 14
    int d = x * 3;    // 21
    int e = x * 8;    // 56
    int f = 0 * x;    // 0 (constant on left)
    int g = 1 * x;    // 7 (constant on left)
    int h = x * -1;   // -7
    int i = x * -3;   // -21
    return a + b + c + d + e + f + g + h + i;
    // 0 + 7 + 14 + 21 + 56 + 0 + 7 + (-7) + (-21) = 77
}
