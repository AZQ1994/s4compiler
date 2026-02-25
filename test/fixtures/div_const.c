// Test trivial constant specialization for division/remainder
// Expected return: 100
int main() {
    int x = 42;
    int a = x / 1;     // 42
    int b = x / -1;    // -42
    int c = x % 1;     // 0
    int d = x % -1;    // 0
    int e = 0 / x;     // 0
    int f = 0 % x;     // 0
    return a + b + c + d + e + f + 100;
    // 42 + (-42) + 0 + 0 + 0 + 0 + 100 = 100
}
