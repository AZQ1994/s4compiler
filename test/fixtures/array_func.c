// Pass array to function and compute sum
int sum_array(int *arr, int n) {
    int s = 0;
    for (int i = 0; i < n; i++) {
        s = s + arr[i];
    }
    return s;
}

int main() {
    int a[4];
    a[0] = 100;
    a[1] = 200;
    a[2] = 300;
    a[3] = 400;
    return sum_array(a, 4); // expected: 1000
}
