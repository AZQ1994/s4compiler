int main() {
    int a = 5;
    int b = -1;  // unsigned: UINT_MAX

    // ult: 5 < UINT_MAX = true (1), UINT_MAX < 5 = false (0)
    int r1 = (unsigned)a < (unsigned)b ? 1 : 0;   // 1
    int r2 = (unsigned)b < (unsigned)a ? 1 : 0;   // 0

    // ult: equal case → false
    int r3 = (unsigned)a < (unsigned)a ? 1 : 0;   // 0

    // ule: equal case → true
    int r4 = (unsigned)a <= (unsigned)a ? 1 : 0;  // 1

    // ugt: 5 > UINT_MAX = false (0)
    int r5 = (unsigned)a > (unsigned)b ? 1 : 0;   // 0

    // uge: UINT_MAX >= 5 = true (1)
    int r6 = (unsigned)b >= (unsigned)a ? 1 : 0;  // 1

    // both negative: -2 < -1 unsigned → -2 (UINT_MAX-1) < -1 (UINT_MAX) → true
    int c = -2;
    int r7 = (unsigned)c < (unsigned)b ? 1 : 0;   // 1

    return r1 + r2 + r3 + r4 + r5 + r6 + r7;     // 1+0+0+1+0+1+1 = 4
}
