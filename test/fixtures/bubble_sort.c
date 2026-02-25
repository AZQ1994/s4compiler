// Bubble sort and return first element (minimum)
int main() {
    int a[5];
    a[0] = 50;
    a[1] = 20;
    a[2] = 40;
    a[3] = 10;
    a[4] = 30;

    // Bubble sort (ascending)
    int n = 5;
    for (int i = 0; i < n - 1; i++) {
        for (int j = 0; j < n - i - 1; j++) {
            if (a[j] > a[j + 1]) {
                int tmp = a[j];
                a[j] = a[j + 1];
                a[j + 1] = tmp;
            }
        }
    }

    // Return sorted[0] + sorted[4] = 10 + 50 = 60
    return a[0] + a[4];
}
