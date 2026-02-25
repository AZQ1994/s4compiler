// Test that exercises phi nodes when compiled with -O1
// min(a, b) using ternary: (a < b) ? a : b
int min(int a, int b) {
    return (a < b) ? a : b;
}

int main() {
    // min(7, 3) + min(2, 9) = 3 + 2 = 5
    return min(7, 3) + min(2, 9);
}
