// 2x2 matrix multiply, return sum of result elements
// A = {{1,2},{3,4}}, B = {{5,6},{7,8}}
// C = A*B = {{1*5+2*7, 1*6+2*8}, {3*5+4*7, 3*6+4*8}}
//         = {{19, 22}, {43, 50}}
// sum = 19+22+43+50 = 134
int main() {
    int a[4]; // 2x2 stored flat
    int b[4];
    int c[4];

    // A = {{1,2},{3,4}}
    a[0] = 1; a[1] = 2;
    a[2] = 3; a[3] = 4;

    // B = {{5,6},{7,8}}
    b[0] = 5; b[1] = 6;
    b[2] = 7; b[3] = 8;

    // C = A * B (2x2)
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            int sum = 0;
            for (int k = 0; k < 2; k++) {
                sum = sum + a[i * 2 + k] * b[k * 2 + j];
            }
            c[i * 2 + j] = sum;
        }
    }

    // Return sum of all elements
    int total = 0;
    for (int i = 0; i < 4; i++) {
        total = total + c[i];
    }
    return total; // expected: 134
}
