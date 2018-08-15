// core 1: AB CD
// core 2: AB CD

-5000: -5000
-10000: -10000
buf1: &data//&buf1_start
bp1: &write_start
C: -5000//-10000

temp : 0
-1 : -1
1: 1
0: 0

B: 0

-5000, buf1, B_POINTER

NEW_B:
0 ,B_POINTER: 0, B
-1, B_POINTER, B_POINTER

COMP:
SHARED_IN, B, temp, L_B_less
L_A_less:
// WRITE A
write_offset1, bp1, W01
0, SHARED_IN, W01: 0
// count
-1, C, C, skip1
0, -1, temp, HALT
skip1: 1, write_offset1, write_offset1, COMP

L_B_less:
0, B, B_12
// new B

// count
-1, C, C, NEW_B
0, -1, temp, HALT
