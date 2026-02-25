// Collatz conjecture: count steps to reach 1
int collatz_steps(int n) {
    int steps = 0;
    while (n != 1) {
        if (n % 2 == 0) {
            n = n / 2;
        } else {
            n = 3 * n + 1;
        }
        steps = steps + 1;
    }
    return steps;
}

int main() {
    // collatz_steps(27) = 111
    return collatz_steps(27);
}
